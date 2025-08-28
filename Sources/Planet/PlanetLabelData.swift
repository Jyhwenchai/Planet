//
//  PlanetLabelData.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  内部标签数据模型 - 管理3D位置、UI层、状态等信息
//

import UIKit

// MARK: - 内部标签数据

/// 内部使用的标签数据结构 - 包含完整的3D和UI信息
internal class PlanetLabelData<T: PlanetLabelRepresentable> {
    
    // MARK: - 标识和原始数据
    
    /// 唯一标识符
    let id: String
    
    /// 原始用户数据
    let originalData: T
    
    /// 数组中的索引
    var index: Int
    
    // MARK: - 3D空间信息
    
    /// 原始3D位置（球面坐标，归一化）
    let originalPosition: Vector3
    
    /// 当前3D位置（经过旋转变换后）
    private(set) var currentPosition: Vector3
    
    /// 2D屏幕投影位置
    private(set) var screenPosition: CGPoint = .zero
    
    /// 深度值（Z坐标，用于排序和视觉效果）
    private(set) var depth: CGFloat = 0
    
    /// 是否在正面（可见）
    private(set) var isFrontFacing: Bool = true
    
    // MARK: - 显示属性
    
    /// 标签标题
    let title: String
    
    /// 标签副标题
    let subtitle: String?
    
    /// 标签颜色
    let color: UIColor
    
    /// 标签图标
    let icon: UIImage?
    
    /// 自定义数据
    let customData: [String: Any]?
    
    // MARK: - UI 层引用
    
    /// 容器层（包含所有子层）
    private(set) var containerLayer: CALayer?
    
    /// 文本层（MarqueeLabel 或普通标签）
    private(set) var textLayer: CALayer?
    
    /// 圆圈层
    private(set) var circleLayer: CALayer?
    
    /// 图标层
    private(set) var iconLayer: CALayer?
    
    // MARK: - 状态信息
    
    /// 是否当前可见
    private(set) var isVisible: Bool = true
    
    /// 是否被选中
    private(set) var isSelected: Bool = false
    
    /// 当前透明度
    private(set) var currentOpacity: Float = 1.0
    
    /// 当前缩放比例
    private(set) var currentScale: CGFloat = 1.0
    
    /// 上次更新时间
    private(set) var lastUpdateTime: TimeInterval = 0
    
    // MARK: - 初始化
    
    /// 初始化标签数据
    /// - Parameters:
    ///   - originalData: 原始用户数据
    ///   - position: 3D位置
    ///   - index: 在数组中的索引
    ///   - defaultColors: 默认颜色数组
    init(originalData: T, position: Vector3, index: Int, defaultColors: [UIColor]) {
        self.id = UUID().uuidString
        self.originalData = originalData
        self.originalPosition = position.normalized()
        self.currentPosition = position.normalized()
        self.index = index
        
        // 提取显示属性
        self.title = originalData.planetTitle
        
        if let customizable = originalData as? PlanetLabelCustomizable {
            self.subtitle = customizable.planetSubtitle
            self.color = customizable.planetColor ?? defaultColors[index % defaultColors.count]
            self.icon = customizable.planetIcon
            self.customData = customizable.planetCustomData
        } else {
            self.subtitle = nil
            self.color = defaultColors[index % defaultColors.count]
            self.icon = nil
            self.customData = nil
        }
        
        self.lastUpdateTime = CACurrentMediaTime()
    }
    
    // MARK: - 3D变换更新
    
    /// 更新3D位置（应用旋转变换）
    /// - Parameter quaternion: 旋转四元数
    func updatePosition(with quaternion: Quaternion) {
        currentPosition = quaternion.rotate(vector: originalPosition)
        lastUpdateTime = CACurrentMediaTime()
    }
    
    /// 更新屏幕投影信息
    /// - Parameters:
    ///   - center: 屏幕中心点
    ///   - radius: 投影半径
    ///   - enableBackfaceCulling: 是否启用背面剔除
    func updateScreenProjection(center: CGPoint, radius: CGFloat, enableBackfaceCulling: Bool) {
        // 计算2D屏幕位置
        screenPosition = CGPoint(
            x: center.x + currentPosition.x * radius,
            y: center.y - currentPosition.y * radius  // Y轴翻转
        )
        
        // 更新深度信息
        depth = currentPosition.z
        
        // 判断是否在正面
        if enableBackfaceCulling {
            isFrontFacing = depth >= 0
        } else {
            isFrontFacing = true
        }
        
        // 更新可见性
        isVisible = isFrontFacing
    }
    
    // MARK: - UI层管理
    
    /// 设置容器层
    /// - Parameter layer: 容器层
    func setContainerLayer(_ layer: CALayer) {
        containerLayer = layer
    }
    
    /// 设置文本层
    /// - Parameter layer: 文本层
    func setTextLayer(_ layer: CALayer) {
        textLayer = layer
    }
    
    /// 设置圆圈层
    /// - Parameter layer: 圆圈层
    func setCircleLayer(_ layer: CALayer) {
        circleLayer = layer
    }
    
    /// 设置图标层
    /// - Parameter layer: 图标层
    func setIconLayer(_ layer: CALayer) {
        iconLayer = layer
    }
    
    /// 清理所有UI层引用
    func clearUIReferences() {
        containerLayer?.removeFromSuperlayer()
        containerLayer = nil
        textLayer = nil
        circleLayer = nil
        iconLayer = nil
    }
    
    // MARK: - 视觉效果更新
    
    /// 更新深度效果
    /// - Parameter config: 深度效果配置  
    func updateDepthEffects(with config: DepthEffectsConfig) {
        guard let container = containerLayer else { return }
        
        // 🔧 借鉴 planet-soul：提前计算，减少 CATransaction 内的工作量
        let normalizedDepth = (depth + 1.0) / 2.0  // 将-1到1映射到0到1
        let alpha = PlanetMath.lerp(
            CGFloat(config.depthAlphaRange.lowerBound),
            CGFloat(config.depthAlphaRange.upperBound),
            t: normalizedDepth
        )
        
        let scale = PlanetMath.lerp(
            CGFloat(config.depthScaleRange.lowerBound),
            CGFloat(config.depthScaleRange.upperBound),
            t: normalizedDepth
        )
        
        // 预计算所有需要的值
        let newOpacity = Float(alpha)
        let newScale = scale
        let transform = CATransform3DMakeScale(scale, scale, 1.0)
        
        var adjustedColor: CGColor? = nil
        if config.enableDepthColorAdjustment, circleLayer != nil {
            let colorIntensity = 1.0 - CGFloat(config.depthColorIntensity) * (1.0 - normalizedDepth)
            adjustedColor = color.withAlphaComponent(color.cgColor.alpha * colorIntensity).cgColor
        }
        
        // 🚀 关键优化：一次性批量更新所有属性，避免多次 CATransaction
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        container.opacity = newOpacity
        container.transform = transform
        
        if let adjustedColor = adjustedColor, let circle = circleLayer {
            circle.backgroundColor = adjustedColor
        }
        
        CATransaction.commit()
        
        // 更新缓存的状态
        currentOpacity = newOpacity
        currentScale = newScale
    }
    
    /// 更新屏幕位置
    /// - Parameter position: 新的屏幕位置
    func updateScreenPosition(_ position: CGPoint) {
        guard let container = containerLayer else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        container.position = position
        CATransaction.commit()
        
        screenPosition = position
    }
    
    /// 设置可见性
    /// - Parameter visible: 是否可见
    func setVisible(_ visible: Bool) {
        isVisible = visible
        containerLayer?.isHidden = !visible
    }
    
    // MARK: - 选择状态
    
    /// 设置选择状态
    /// - Parameter selected: 是否选中
    func setSelected(_ selected: Bool, animated: Bool = true) {
        guard isSelected != selected else { return }
        isSelected = selected
        
        // 这里可以添加选中状态的视觉效果
        // 具体实现会在主视图中处理
    }
    
    // MARK: - 点击检测
    
    /// 检测点击位置是否在标签范围内
    /// - Parameters:
    ///   - point: 点击位置
    ///   - hitTestConfig: 点击检测配置
    /// - Returns: 是否命中
    func hitTest(point: CGPoint, config: HitTestingConfig) -> Bool {
        guard isVisible, let container = containerLayer else { return false }
        
        // 计算点击区域
        let bounds = container.bounds
        let position = container.position
        let transform = container.transform
        
        // 考虑变换的实际尺寸
        let scaleX = sqrt(transform.m11 * transform.m11 + transform.m12 * transform.m12)
        let scaleY = sqrt(transform.m21 * transform.m21 + transform.m22 * transform.m22)
        
        let scaledWidth = bounds.width * scaleX
        let scaledHeight = bounds.height * scaleY
        
        // 应用最小点击区域限制
        let finalWidth = max(scaledWidth, config.minimumHitAreaSize.width)
        let finalHeight = max(scaledHeight, config.minimumHitAreaSize.height)
        
        // 计算扩展后的点击区域
        let hitArea = CGRect(
            x: position.x - finalWidth/2 - config.hitAreaExpansion,
            y: position.y - finalHeight/2 - config.hitAreaExpansion,
            width: finalWidth + config.hitAreaExpansion * 2,
            height: finalHeight + config.hitAreaExpansion * 2
        )
        
        return hitArea.contains(point)
    }
    
    // MARK: - 动画效果
    
    /// 播放点击动画
    /// - Parameter config: 点击动画配置
    @MainActor func playClickAnimation(with config: ClickAnimationConfig) {
        guard let container = containerLayer else { return }
        
        // 移除之前的动画
        container.removeAllAnimations()
        
        // 缩放动画
        if config.scaleAnimation.isEnabled {
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = currentScale
            scaleAnimation.toValue = currentScale * config.scaleAnimation.maxScale
            scaleAnimation.duration = config.scaleAnimation.duration / 2
            scaleAnimation.autoreverses = true
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: config.scaleAnimation.timingFunction)
            
            container.add(scaleAnimation, forKey: "clickScale")
        }
        
        // 颜色闪烁动画
        if config.colorFlash.isEnabled, let circle = circleLayer {
            let originalColor = circle.backgroundColor
            
            let colorAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
            colorAnimation.values = [
                originalColor as Any,
                config.colorFlash.flashColor.cgColor,
                originalColor as Any
            ]
            colorAnimation.keyTimes = [0.0, 0.5, 1.0]
            colorAnimation.duration = config.colorFlash.duration
            colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            circle.add(colorAnimation, forKey: "colorFlash")
        }
        
        // 震动反馈
        if config.hapticFeedback.isEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: config.hapticFeedback.impactStyle)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }
    }
    
    /// 播放选择状态动画
    /// - Parameters:
    ///   - selected: 是否选中
    ///   - config: 选择状态配置
    func playSelectionAnimation(selected: Bool, with config: SelectedAppearanceConfig) {
        guard let container = containerLayer else { return }
        
        let targetScale = selected ? (currentScale * config.scaleMultiplier) : currentScale
        let targetAlpha = selected ? config.alpha : CGFloat(currentOpacity)
        
        if config.animationDuration > 0 {
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = container.transform.m11
            scaleAnimation.toValue = targetScale
            scaleAnimation.duration = config.animationDuration
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = .forwards
            
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.fromValue = container.opacity
            alphaAnimation.toValue = Float(targetAlpha)
            alphaAnimation.duration = config.animationDuration
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            alphaAnimation.isRemovedOnCompletion = false
            alphaAnimation.fillMode = .forwards
            
            container.add(scaleAnimation, forKey: "selectionScale")
            container.add(alphaAnimation, forKey: "selectionAlpha")
        } else {
            // 立即应用
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            container.transform = CATransform3DMakeScale(targetScale, targetScale, 1.0)
            container.opacity = Float(targetAlpha)
            CATransaction.commit()
        }
    }
}

// MARK: - 内部标签管理器

/// 标签数据管理器 - 负责创建、更新、销毁标签数据
internal class PlanetLabelManager<T: PlanetLabelRepresentable> {
    
    // MARK: - 属性
    
    /// 所有标签数据
    private(set) var labelData: [PlanetLabelData<T>] = []
    
    /// 配置
    private let configuration: PlanetConfiguration
    
    /// 默认颜色数组
    private let defaultColors: [UIColor]
    
    /// 回收的UI层缓存
    private var recycledContainerLayers: [CALayer] = []
    private var recycledTextLayers: [CALayer] = []
    private var recycledCircleLayers: [CALayer] = []
    
    // MARK: - 初始化
    
    /// 初始化管理器
    /// - Parameter configuration: 配置
    init(configuration: PlanetConfiguration) {
        self.configuration = configuration
        self.defaultColors = configuration.appearance.labelStyle.defaultLabelColors
    }
    
    // MARK: - 数据管理
    
    /// 更新标签数据
    /// - Parameters:
    ///   - newData: 新的数据数组
    ///   - distributionPoints: 分布点数组
    func updateLabels(_ newData: [T], distributionPoints: [Vector3]) {
        // 清理旧数据
        clearAllLabels()
        
        // 创建新数据
        labelData = []
        
        for (index, data) in newData.enumerated() {
            let position = index < distributionPoints.count ? 
                distributionPoints[index] : 
                Vector3(x: 0, y: 1, z: 0)  // 默认位置
            
            let newLabelData = PlanetLabelData(
                originalData: data,
                position: position,
                index: index,
                defaultColors: defaultColors
            )
            
            self.labelData.append(newLabelData)
        }
    }
    
    /// 清理所有标签
    func clearAllLabels() {
        for data in labelData {
            recycleLabelUI(data)
        }
        labelData.removeAll()
    }
    
    /// 回收标签的UI资源
    /// - Parameter labelData: 要回收的标签数据
    private func recycleLabelUI(_ labelData: PlanetLabelData<T>) {
        if let container = labelData.containerLayer {
            recycledContainerLayers.append(container)
        }
        
        if let text = labelData.textLayer {
            recycledTextLayers.append(text)
        }
        
        if let circle = labelData.circleLayer {
            recycledCircleLayers.append(circle)
        }
        
        labelData.clearUIReferences()
    }
    
    // MARK: - 查询方法
    
    /// 根据ID获取标签数据
    /// - Parameter id: 标签ID
    /// - Returns: 标签数据
    func labelData(for id: String) -> PlanetLabelData<T>? {
        return labelData.first { $0.id == id }
    }
    
    /// 根据索引获取标签数据
    /// - Parameter index: 索引
    /// - Returns: 标签数据
    func labelData(at index: Int) -> PlanetLabelData<T>? {
        guard index >= 0 && index < labelData.count else { return nil }
        return labelData[index]
    }
    
    /// 根据点击位置获取标签数据
    /// - Parameters:
    ///   - point: 点击位置
    ///   - config: 点击检测配置
    /// - Returns: 命中的标签数据（按深度排序，最前面的优先）
    func labelData(at point: CGPoint, config: HitTestingConfig) -> PlanetLabelData<T>? {
        var hitCandidates: [(data: PlanetLabelData<T>, depth: CGFloat)] = []
        
        for data in labelData {
            if data.hitTest(point: point, config: config) {
                hitCandidates.append((data: data, depth: data.depth))
            }
        }
        
        // 如果启用3D深度检测，返回最前面的
        if config.enable3DDepthTesting {
            return hitCandidates.max(by: { $0.depth < $1.depth })?.data
        } else {
            return hitCandidates.first?.data
        }
    }
    
    /// 获取所有可见的标签数据
    /// - Returns: 可见标签数据数组
    func visibleLabelData() -> [PlanetLabelData<T>] {
        return labelData.filter { $0.isVisible }
    }
    
    /// 获取所有选中的标签数据
    /// - Returns: 选中标签数据数组
    func selectedLabelData() -> [PlanetLabelData<T>] {
        return labelData.filter { $0.isSelected }
    }
    
    // MARK: - 批量操作
    
    /// 批量更新所有标签的3D位置
    /// - Parameter quaternion: 旋转四元数
    func updateAllPositions(with quaternion: Quaternion) {
        for data in labelData {
            data.updatePosition(with: quaternion)
        }
    }
    
    /// 批量更新所有标签的屏幕投影
    /// - Parameters:
    ///   - center: 屏幕中心
    ///   - radius: 投影半径
    func updateAllScreenProjections(center: CGPoint, radius: CGFloat) {
        let enableBackfaceCulling = configuration.appearance.depthEffects.enableBackfaceCulling
        
        for data in labelData {
            data.updateScreenProjection(
                center: center,
                radius: radius,
                enableBackfaceCulling: enableBackfaceCulling
            )
        }
    }
    
    /// 批量更新所有标签的深度效果
    func updateAllDepthEffects() {
        let depthConfig = configuration.appearance.depthEffects
        
        for data in labelData {
            data.updateDepthEffects(with: depthConfig)
        }
    }
    
    // MARK: - 内存管理
    
    /// 清理回收缓存
    func clearRecycleCache() {
        recycledContainerLayers.removeAll()
        recycledTextLayers.removeAll()
        recycledCircleLayers.removeAll()
    }
    
    /// 获取回收的容器层
    /// - Returns: 回收的容器层，如果没有则返回nil
    func getRecycledContainerLayer() -> CALayer? {
        return recycledContainerLayers.popLast()
    }
    
    /// 获取回收的文本层
    /// - Returns: 回收的文本层，如果没有则返回nil
    func getRecycledTextLayer() -> CALayer? {
        return recycledTextLayers.popLast()
    }
    
    /// 获取回收的圆圈层
    /// - Returns: 回收的圆圈层，如果没有则返回nil
    func getRecycledCircleLayer() -> CALayer? {
        return recycledCircleLayers.popLast()
    }
}

// MARK: - 便利扩展

internal extension Array where Element: AnyObject {
    /// 安全的 popLast 方法
    mutating func popLast() -> Element? {
        return isEmpty ? nil : removeLast()
    }
}
