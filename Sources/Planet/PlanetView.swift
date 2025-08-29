//
//  PlanetView.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  核心星球视图组件 - 泛型实现，支持任意标签数据类型
//

import UIKit
import Combine

// MARK: - 动画引擎相关类型定义

/// 动画状态
internal enum AnimationState {
    case idle                          // 空闲状态
    case autoRotation                 // 自动旋转
    case inertiaScrolling            // 惯性滚动
    case customAnimation             // 自定义动画
}

/// 自定义动画数据
internal struct CustomAnimationData {
    let startRotation: Quaternion
    let targetRotation: Quaternion
    let startScale: CGFloat
    let targetScale: CGFloat
    let startTime: TimeInterval
    let duration: TimeInterval
    let completion: (() -> Void)?
    
    func progress(at currentTime: TimeInterval) -> CGFloat {
        guard duration > 0 else { return 1.0 }
        return min(1.0, CGFloat((currentTime - startTime) / duration))
    }
}

// MARK: - 事件回调类型定义

/// 标签点击事件回调
public typealias LabelTapHandler<T> = (T, Int) -> Void


/// 旋转状态改变回调
public typealias RotationStateHandler = (Quaternion) -> Void

/// 缩放状态改变回调
public typealias ScaleStateHandler = (CGFloat) -> Void

// MARK: - 核心星球视图

/// 泛型星球视图 - 支持任意实现了PlanetLabelRepresentable协议的数据类型
public class PlanetView<T: PlanetLabelRepresentable>: UIView {
    
    // MARK: - 公共属性
    
    /// 配置
    public var configuration: PlanetConfiguration {
        didSet {
            applyConfiguration()
        }
    }
    
    /// 标签数据
    public private(set) var labels: [T] = []
    
    /// 当前旋转四元数
    public internal(set) var currentRotation: Quaternion = .identity
    
    /// 当前缩放比例
    public internal(set) var currentScale: CGFloat = 1.0
    
    // MARK: - @objc 手势处理方法
    
    @objc internal func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        handlePanGesture(gesture)
    }
    
    @objc internal func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        handleTapGesture(gesture)
    }
    
    
    @objc internal func doubleTapGestureHandler(_ gesture: UITapGestureRecognizer) {
        handleDoubleTapGesture(gesture)
    }
    
    @objc internal func pinchGestureHandler(_ gesture: UIPinchGestureRecognizer) {
        handlePinchGesture(gesture)
    }
    
    /// 处理内存警告通知
    @objc internal func handleMemoryWarningNotification() {
        handleMemoryWarning()
    }
    
    /// CADisplayLink 每帧更新回调 - 与屏幕刷新率完美同步
    @objc internal func animationFrameUpdate() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastFrameTime
        lastFrameTime = currentTime
        
        // 检查是否需要停止动画
        guard shouldContinueAnimation() else {
            stopAnimationEngine()
            // 🔧 移除这里的自动启动，避免循环启停
            return
        }
        
        // 根据当前状态执行对应的动画逻辑
        switch animationState {
        case .idle:
            stopAnimationEngine()
            
        case .autoRotation:
            updateAutoRotation(deltaTime: deltaTime)
            
        case .inertiaScrolling:
            updateInertiaScrolling(deltaTime: deltaTime)
            
        case .customAnimation:
            updateCustomAnimation(currentTime: currentTime)
        }
    }
    
    // MARK: - 事件回调
    
    /// 标签点击事件
    public var onLabelTap: LabelTapHandler<T>?
    
    
    /// 旋转状态改变事件
    public var onRotationChanged: RotationStateHandler?
    
    /// 缩放状态改变事件
    public var onScaleChanged: ScaleStateHandler?
    
    // MARK: - 私有属性
    
    /// 标签数据管理器
    internal var labelManager: PlanetLabelManager<T>
    
    /// 当前星球半径
    internal var planetRadius: CGFloat = 150
    
    /// 星球背景层
    private let planetBackgroundLayer = CAGradientLayer()
    
    /// 标签容器层
    private let labelContainerLayer = CALayer()
    
    /// 手势状态
    internal var isUserInteracting = false
    internal var isInertiaScrolling = false
    internal var inertiaVelocity: CGPoint = .zero
    
    /// 自动旋转和动画引擎
    internal var displayLink: CADisplayLink?
    internal var autoRotationAxis: Vector3 = Vector3.unitY
    internal var autoRotationSpeed: CGFloat = 0.005
    
    /// 动画状态
    internal var animationState: AnimationState = .idle
    internal var lastFrameTime: TimeInterval = 0
    internal var customAnimationData: CustomAnimationData?
    
    // MARK: - 初始化
    
    /// 初始化星球视图
    /// - Parameter configuration: 配置选项
    public init(configuration: PlanetConfiguration = .default) {
        self.configuration = configuration
        self.labelManager = PlanetLabelManager<T>(configuration: configuration)
        
        super.init(frame: .zero)
        setupUI()
        applyConfiguration()
        startAutoRotationIfNeeded()
    }
    
    public required init?(coder: NSCoder) {
        self.configuration = .default
        self.labelManager = PlanetLabelManager<T>(configuration: configuration)
        
        super.init(coder: coder)
        setupUI()
        applyConfiguration()
        startAutoRotationIfNeeded()
    }
    
    deinit {
        // 🔑 清理 CADisplayLink
        MainActor.assumeIsolated {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        // 设置背景层
        layer.addSublayer(planetBackgroundLayer)
        
        // 设置标签容器层
        labelContainerLayer.masksToBounds = false
        layer.addSublayer(labelContainerLayer)
        
        // 设置手势识别
        setupGestures()
        
        // 监听内存警告
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarningNotification),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    internal func applyConfiguration() {
        backgroundColor = configuration.appearance.backgroundColor
        
        // 重新创建标签管理器以应用新配置
        labelManager = PlanetLabelManager<T>(configuration: configuration)
        
        // 重新生成当前标签
        if !labels.isEmpty {
            updateLabels(labels)
        }
        
        // 更新背景层
        updatePlanetBackground()
        
        // 更新手势
        setupGestures()
        
        setNeedsLayout()
    }
    
    // MARK: - 布局
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        // 计算星球半径
        updatePlanetRadius()
        
        // 更新背景层
        updatePlanetBackground()
        
        // 更新标签容器
        labelContainerLayer.frame = bounds
        
        // 重新计算标签位置
        updateAllLabelPositions()
    }
    
    private func updatePlanetRadius() {
        let config = configuration.layout.radiusCalculation
        
        switch config.mode {
        case .proportionalToView:
            planetRadius = min(bounds.width, bounds.height) * config.proportionFactor
            
        case .fixed:
            planetRadius = config.fixedRadius
            
        case .adaptive:
            // 基于标签数量自适应调整
            let baseFactor = config.proportionFactor
            let labelCountFactor = sqrt(CGFloat(labels.count)) / 10.0  // 标签越多，半径相对越大
            let adaptiveFactor = baseFactor * (1.0 + labelCountFactor * 0.2)
            planetRadius = min(bounds.width, bounds.height) * adaptiveFactor
        }
        
        // 应用限制
        planetRadius = PlanetMath.clamp(
            planetRadius,
            min: config.minimumRadius,
            max: config.maximumRadius
        )
    }
    
    private func updatePlanetBackground() {
        let bgConfig = configuration.appearance.planetBackground
        
        planetBackgroundLayer.isHidden = !bgConfig.isVisible
        
        guard bgConfig.isVisible else { return }
        
        // 计算背景层frame
        let diameter = planetRadius * 2
        let backgroundFrame = CGRect(
            x: (bounds.width - diameter) / 2,
            y: (bounds.height - diameter) / 2,
            width: diameter,
            height: diameter
        )
        
        planetBackgroundLayer.frame = backgroundFrame
        planetBackgroundLayer.cornerRadius = planetRadius
        
        // 配置背景类型
        switch bgConfig.backgroundType {
        case .none:
            planetBackgroundLayer.isHidden = true
            
        case .gradient:
            planetBackgroundLayer.type = .radial
            planetBackgroundLayer.colors = bgConfig.gradientColors.map { $0.cgColor }
            planetBackgroundLayer.locations = bgConfig.gradientLocations.map { NSNumber(value: $0) }
            planetBackgroundLayer.startPoint = bgConfig.gradientStartPoint
            planetBackgroundLayer.endPoint = bgConfig.gradientEndPoint
            
        case .solid:
            planetBackgroundLayer.backgroundColor = bgConfig.solidColor.cgColor
            planetBackgroundLayer.colors = nil
            
        case .image:
            if let image = bgConfig.backgroundImage {
                planetBackgroundLayer.contents = image.cgImage
                planetBackgroundLayer.contentsGravity = contentModeToGravity(bgConfig.imageContentMode)
            }
            
        case .custom:
            // 自定义背景由用户通过其他方式提供
            break
        }
    }
    
    private func contentModeToGravity(_ contentMode: UIView.ContentMode) -> CALayerContentsGravity {
        switch contentMode {
        case .scaleToFill: return .resize
        case .scaleAspectFit: return .resizeAspect
        case .scaleAspectFill: return .resizeAspectFill
        case .center: return .center
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomLeft: return .bottomLeft
        case .bottomRight: return .bottomRight
        case .redraw: return .resizeAspect
        @unknown default: return .resizeAspect
        }
    }
}

// MARK: - 数据管理

public extension PlanetView {
    
    /// 更新标签数据
    /// - Parameter newLabels: 新的标签数组
    func updateLabels(_ newLabels: [T]) {
        labels = newLabels
        
        // 生成分布点
        let distributionPoints = PlanetDistribution.generateFibonacciPoints(count: newLabels.count)
        
        // 更新标签管理器
        labelManager.updateLabels(newLabels, distributionPoints: distributionPoints)
        
        // 创建UI层
        createLabelLayers()
        
        // 更新显示
        updateAllLabelPositions()
        
        print("🌟 已更新 \(newLabels.count) 个标签")
    }
    
    /// 添加单个标签
    /// - Parameter label: 要添加的标签
    func addLabel(_ label: T) {
        labels.append(label)
        updateLabels(labels)
    }
    
    /// 移除指定索引的标签
    /// - Parameter index: 要移除的标签索引
    func removeLabel(at index: Int) {
        guard index >= 0 && index < labels.count else { return }
        labels.remove(at: index)
        updateLabels(labels)
    }
    
    /// 清空所有标签
    func clearAllLabels() {
        labels.removeAll()
        labelManager.clearAllLabels()
        updateAllLabelPositions()
    }
    
    /// 获取指定索引的标签数据
    /// - Parameter index: 标签索引
    /// - Returns: 标签数据
    func getLabel(at index: Int) -> T? {
        guard index >= 0 && index < labels.count else { return nil }
        return labels[index]
    }
}

// MARK: - UI层创建和管理

private extension PlanetView {
    
    /// 创建所有标签的UI层
    func createLabelLayers() {
        // 清理现有层
        labelContainerLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let labelStyle = configuration.appearance.labelStyle
        
        for labelData in labelManager.labelData {
            createSingleLabelLayer(for: labelData, style: labelStyle)
        }
    }
    
    /// 创建单个标签的UI层
    /// - Parameters:
    ///   - labelData: 标签数据
    ///   - style: 标签样式配置
    func createSingleLabelLayer(for labelData: PlanetLabelData<T>, style: LabelStyleConfig) {
        // 创建容器层
        let container = CALayer()
        container.masksToBounds = false
        
        // 创建文本层
        var textLayer: CALayer?
        if shouldShowText(for: style.layoutType) {
            textLayer = createTextLayer(for: labelData, style: style.textStyle)
            if let textLayer = textLayer {
                container.addSublayer(textLayer)
            }
        }
        
        // 创建圆圈层
        var circleLayer: CALayer?
        if shouldShowCircle(for: style.layoutType) {
            circleLayer = createCircleLayer(for: labelData, style: style.circleStyle)
            if let circleLayer = circleLayer {
                container.addSublayer(circleLayer)
            }
        }
        
        // 创建图标层（如果有）
        var iconLayer: CALayer?
        if let icon = labelData.icon {
            iconLayer = createIconLayer(with: icon)
            if let iconLayer = iconLayer {
                container.addSublayer(iconLayer)
            }
        }
        
        // 布局子层
        layoutLabelSubLayers(
            container: container,
            textLayer: textLayer,
            circleLayer: circleLayer,
            iconLayer: iconLayer,
            layoutType: style.layoutType,
            spacing: style.spacing
        )
        
        // 保存层引用
        labelData.setContainerLayer(container)
        if let textLayer = textLayer {
            labelData.setTextLayer(textLayer)
        }
        if let circleLayer = circleLayer {
            labelData.setCircleLayer(circleLayer)
        }
        if let iconLayer = iconLayer {
            labelData.setIconLayer(iconLayer)
        }
        
        // 添加到容器
        labelContainerLayer.addSublayer(container)
    }
    
    /// 创建文本层
    func createTextLayer(for labelData: PlanetLabelData<T>, style: TextStyleConfig) -> CALayer? {
        if style.enableMarquee {
            // 使用跑马灯标签
            let marqueeLayer = MarqueeTextLayer()
            marqueeLayer.contentsScale = UIScreen.main.scale
            marqueeLayer.text = labelData.title
            marqueeLayer.textColor = style.color
            marqueeLayer.font = style.font
            marqueeLayer.maxWidth = style.maxWidth
            
            // 应用跑马灯配置
            let marqueeConfig = style.marqueeConfig
            marqueeLayer.scrollSpeed = marqueeConfig.scrollSpeed
            marqueeLayer.scrollInterval = marqueeConfig.scrollDelay
            marqueeLayer.fadeEdgeWidth = marqueeConfig.fadeEdgeWidth
            marqueeLayer.enableFadeEdge = marqueeConfig.enableFadeEdge
            
            return marqueeLayer
        } else {
            // 使用普通文本层
            let textLayer = CATextLayer()
            textLayer.string = labelData.title
            textLayer.font = style.font
            textLayer.fontSize = style.font.pointSize
            textLayer.foregroundColor = style.color.cgColor
            textLayer.backgroundColor = UIColor.clear.cgColor
            textLayer.alignmentMode = .center
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.isWrapped = false
            
            // 计算文本尺寸
            let attributes: [NSAttributedString.Key: Any] = [.font: style.font]
            let textSize = (labelData.title as NSString).size(withAttributes: attributes)
            textLayer.frame = CGRect(origin: .zero, size: textSize)
            
            // 应用文本阴影
            if let shadowConfig = style.shadowConfig {
                textLayer.shadowColor = shadowConfig.color.cgColor
                textLayer.shadowOffset = shadowConfig.offset
                textLayer.shadowRadius = shadowConfig.blurRadius
                textLayer.shadowOpacity = shadowConfig.opacity
            }
            
            return textLayer
        }
    }
    
    /// 创建圆圈层
    func createCircleLayer(for labelData: PlanetLabelData<T>, style: CircleStyleConfig) -> CALayer {
        let circleLayer = CALayer()
        circleLayer.backgroundColor = labelData.color.cgColor
        circleLayer.cornerRadius = style.size / 2
        circleLayer.frame = CGRect(origin: .zero, size: CGSize(width: style.size, height: style.size))
        
        // 边框
        if style.borderWidth > 0 {
            circleLayer.borderWidth = style.borderWidth
            circleLayer.borderColor = style.borderColor.cgColor
        }
        
        // 渐变填充
        if style.useGradientFill && !style.gradientColors.isEmpty {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = circleLayer.bounds
            gradientLayer.colors = style.gradientColors.map { $0.cgColor }
            gradientLayer.cornerRadius = style.size / 2
            circleLayer.addSublayer(gradientLayer)
        }
        
        // 阴影
        if let shadowConfig = style.shadowConfig {
            circleLayer.shadowColor = shadowConfig.color.cgColor
            circleLayer.shadowOffset = shadowConfig.offset
            circleLayer.shadowRadius = shadowConfig.radius
            circleLayer.shadowOpacity = shadowConfig.opacity
        }
        
        return circleLayer
    }
    
    /// 创建图标层
    func createIconLayer(with icon: UIImage) -> CALayer {
        let iconLayer = CALayer()
        iconLayer.contents = icon.cgImage
        iconLayer.contentsGravity = .resizeAspect
        iconLayer.frame = CGRect(origin: .zero, size: CGSize(width: 20, height: 20))
        return iconLayer
    }
    
    /// 判断是否应该显示文本
    func shouldShowText(for layoutType: LabelLayoutType) -> Bool {
        switch layoutType {
        case .textAboveCircle, .textBelowCircle, .textOnly, .textLeftCircle, .textRightCircle:
            return true
        case .circleOnly:
            return false
        }
    }
    
    /// 判断是否应该显示圆圈
    func shouldShowCircle(for layoutType: LabelLayoutType) -> Bool {
        switch layoutType {
        case .textAboveCircle, .textBelowCircle, .circleOnly, .textLeftCircle, .textRightCircle:
            return true
        case .textOnly:
            return false
        }
    }
    
    /// 布局标签的子层
    func layoutLabelSubLayers(
        container: CALayer,
        textLayer: CALayer?,
        circleLayer: CALayer?,
        iconLayer: CALayer?,
        layoutType: LabelLayoutType,
        spacing: SpacingConfig
    ) {
        let textSize = textLayer?.bounds.size ?? .zero
        let circleSize = circleLayer?.bounds.size ?? .zero
        let iconSize = iconLayer?.bounds.size ?? .zero
        
        var totalSize: CGSize = .zero
        
        // 根据布局类型计算总尺寸和位置
        switch layoutType {
        case .textAboveCircle:
            totalSize = CGSize(
                width: max(textSize.width, circleSize.width),
                height: textSize.height + spacing.textToCircle + circleSize.height
            )
            
            textLayer?.position = CGPoint(x: totalSize.width / 2, y: textSize.height / 2)
            circleLayer?.position = CGPoint(
                x: totalSize.width / 2,
                y: textSize.height + spacing.textToCircle + circleSize.height / 2
            )
            
        case .textBelowCircle:
            totalSize = CGSize(
                width: max(textSize.width, circleSize.width),
                height: circleSize.height + spacing.textToCircle + textSize.height
            )
            
            circleLayer?.position = CGPoint(x: totalSize.width / 2, y: circleSize.height / 2)
            textLayer?.position = CGPoint(
                x: totalSize.width / 2,
                y: circleSize.height + spacing.textToCircle + textSize.height / 2
            )
            
        case .textOnly:
            totalSize = textSize
            textLayer?.position = CGPoint(x: totalSize.width / 2, y: totalSize.height / 2)
            
        case .circleOnly:
            totalSize = circleSize
            circleLayer?.position = CGPoint(x: totalSize.width / 2, y: totalSize.height / 2)
            
        case .textLeftCircle:
            totalSize = CGSize(
                width: textSize.width + spacing.textToCircle + circleSize.width,
                height: max(textSize.height, circleSize.height)
            )
            
            textLayer?.position = CGPoint(x: textSize.width / 2, y: totalSize.height / 2)
            circleLayer?.position = CGPoint(
                x: textSize.width + spacing.textToCircle + circleSize.width / 2,
                y: totalSize.height / 2
            )
            
        case .textRightCircle:
            totalSize = CGSize(
                width: circleSize.width + spacing.textToCircle + textSize.width,
                height: max(textSize.height, circleSize.height)
            )
            
            circleLayer?.position = CGPoint(x: circleSize.width / 2, y: totalSize.height / 2)
            textLayer?.position = CGPoint(
                x: circleSize.width + spacing.textToCircle + textSize.width / 2,
                y: totalSize.height / 2
            )
        }
        
        // 设置容器尺寸
        container.bounds = CGRect(origin: .zero, size: totalSize)
        
        // 添加图标层（如果有）
        if let iconLayer = iconLayer {
            // 图标默认放在右上角
            iconLayer.position = CGPoint(
                x: totalSize.width - iconSize.width / 2,
                y: iconSize.height / 2
            )
        }
    }
}

// MARK: - 位置更新和渲染

internal extension PlanetView {
    
    /// 更新所有标签位置 - 借鉴 planet-soul 的优化策略
    func updateAllLabelPositions() {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let scaledRadius = planetRadius * currentScale
        
        // 🔧 首先批量更新数据层（无UI操作）
        labelManager.updateAllPositions(with: currentRotation)
        labelManager.updateAllScreenProjections(center: center, radius: scaledRadius)
        labelManager.updateAllDepthEffects()
        
        // 🚀 关键优化：使用单个 CATransaction 批量更新所有UI层
        // 这样避免了每个标签都创建CATransaction，大幅提高性能
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for labelData in labelManager.labelData {
            if let container = labelData.containerLayer {
                container.position = labelData.screenPosition
                container.isHidden = !labelData.isVisible
            }
        }
        
        CATransaction.commit()
        
        // 通知旋转状态改变
        onRotationChanged?(currentRotation)
    }
}

// MARK: - 内存管理

// MARK: - 内存管理

private extension PlanetView {
    
    /// 处理内存警告
    func handleMemoryWarning() {
        if configuration.performance.memory.autoClearOnMemoryWarning {
            labelManager.clearRecycleCache()
        }
    }
}

// MARK: - 便利方法

public extension PlanetView {
    
    /// 重置旋转到初始状态
    func resetRotation() {
        currentRotation = .identity
        updateAllLabelPositions()
    }
    
    /// 设置旋转
    /// - Parameter quaternion: 新的旋转四元数
    func setRotation(_ quaternion: Quaternion) {
        currentRotation = quaternion.normalized()
        updateAllLabelPositions()
    }
    
    /// 设置缩放
    /// - Parameter scale: 缩放比例
    func setScale(_ scale: CGFloat) {
        let config = configuration.animation.gestureResponse.scaling
        let clampedScale = PlanetMath.clamp(scale, min: config.scaleRange.lowerBound, max: config.scaleRange.upperBound)
        
        currentScale = clampedScale
        updateAllLabelPositions()
        onScaleChanged?(currentScale)
    }
    
    /// 获取当前可见的标签数量
    /// - Returns: 可见标签数量
    func visibleLabelCount() -> Int {
        return labelManager.visibleLabelData().count
    }
    
    /// 查找包含指定文本的标签
    /// - Parameter text: 要查找的文本
    /// - Returns: 匹配的标签索引数组
    func findLabels(containing text: String) -> [Int] {
        return labels.enumerated().compactMap { index, label in
            return label.planetTitle.lowercased().contains(text.lowercased()) ? index : nil
        }
    }
}
