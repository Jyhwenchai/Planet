//
//  MarqueeLabel.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  跑马灯文本标签组件 - 支持长文本滚动效果
//

import UIKit

// MARK: - 配置结构体

/// 跑马灯标签配置
public struct MarqueeLabelConfig: Sendable {
    /// 文本颜色
    public var textColor: UIColor = .white
    
    /// 字体
    public var font: UIFont = UIFont.systemFont(ofSize: 12)
    
    /// 最大显示宽度
    public var maxWidth: CGFloat = 100
    
    /// 滚动速度（点/秒）
    public var scrollSpeed: CGFloat = 15
    
    /// 滚动前的延迟时间（秒）
    public var scrollDelay: TimeInterval = 1.0
    
    /// 背景颜色
    public var backgroundColor: UIColor = .clear
    
    /// 渐变边缘宽度
    public var fadeEdgeWidth: CGFloat = 12
    
    /// 文本对齐方式（当不需要滚动时）
    public var textAlignment: CATextLayerAlignmentMode = .center
    
    /// 是否启用渐变边缘效果
    public var enableFadeEdge: Bool = true
    
    /// 公共初始化方法
    public init() {}
}

// MARK: - 跑马灯标签视图

/// 跑马灯文本标签 - UIView 版本，便于集成到视图层次结构
public class MarqueeLabel: UIView {
    
    // MARK: - 公共属性
    
    /// 显示的文本
    public var text: String = "" {
        didSet {
            marqueeLayer.text = text
        }
    }
    
    /// 配置
    public var config: MarqueeLabelConfig = MarqueeLabelConfig() {
        didSet {
            applyConfig()
        }
    }
    
    // MARK: - 私有属性
    
    private let marqueeLayer = MarqueeTextLayer()
    
    // MARK: - 初始化
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    /// 便利初始化方法
    /// - Parameters:
    ///   - text: 显示文本
    ///   - config: 配置选项
    public init(text: String, config: MarqueeLabelConfig = MarqueeLabelConfig()) {
        super.init(frame: .zero)
        self.text = text
        self.config = config
        setupUI()
        marqueeLayer.text = text
      marqueeLayer.contentsScale = UIScreen.main.scale
        applyConfig()
    }
    
    // MARK: - 设置
    
    private func setupUI() {
        backgroundColor = .clear
        layer.addSublayer(marqueeLayer)
    }
    
    private func applyConfig() {
        backgroundColor = config.backgroundColor
        marqueeLayer.textColor = config.textColor
        marqueeLayer.font = config.font
        marqueeLayer.maxWidth = config.maxWidth
        marqueeLayer.scrollSpeed = config.scrollSpeed
        marqueeLayer.scrollInterval = config.scrollDelay
        marqueeLayer.fadeEdgeWidth = config.fadeEdgeWidth
        marqueeLayer.textAlignment = config.textAlignment
        marqueeLayer.enableFadeEdge = config.enableFadeEdge
        
        setNeedsLayout()
    }
    
    // MARK: - 布局
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        marqueeLayer.maxWidth = bounds.width
        marqueeLayer.frame = bounds
    }
    
    // MARK: - 公共方法
    
    /// 暂停滚动动画
    public func pauseScrolling() {
        marqueeLayer.pauseScrolling()
    }
    
    /// 恢复滚动动画
    public func resumeScrolling() {
        marqueeLayer.resumeScrolling()
    }
    
    /// 重新开始滚动动画
    public func restartScrolling() {
        marqueeLayer.restartScrolling()
    }
    
    /// 获取文本的实际尺寸
    /// - Returns: 文本尺寸
    public func textSize() -> CGSize {
        return marqueeLayer.textSize
    }
    
    /// 检查是否需要滚动
    /// - Returns: 如果文本宽度超过最大宽度则返回true
    public func needsScrolling() -> Bool {
        return marqueeLayer.needsScrolling()
    }
}

// MARK: - 跑马灯文本层

/// 跑马灯文本层 - 核心实现
internal class MarqueeTextLayer: CALayer {
    
    // MARK: - 属性
    
    /// 显示的文本
    var text: String = "" {
        didSet {
            updateTextDisplay()
        }
    }
    
    /// 文本颜色
    var textColor: UIColor = .white {
        didSet {
            textLayer.foregroundColor = textColor.cgColor
        }
    }
    
    /// 字体
    var font: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            textLayer.font = font
            textLayer.fontSize = font.pointSize
            updateTextDisplay()
        }
    }
    
    /// 最大显示宽度
    var maxWidth: CGFloat = 100 {
        didSet {
            updateTextDisplay()
        }
    }
    
    /// 滚动速度（点/秒）
    var scrollSpeed: CGFloat = 15
    
    /// 滚动前的延迟时间（秒）
    var scrollInterval: TimeInterval = 1.0
    
    /// 渐变边缘宽度
    var fadeEdgeWidth: CGFloat = 12 {
        didSet {
            if isScrolling {
                setupScrolling()
            }
        }
    }
    
    /// 文本对齐方式
    var textAlignment: CATextLayerAlignmentMode = .center {
        didSet {
            textLayer.alignmentMode = textAlignment
            updateTextDisplay()
        }
    }
    
    /// 是否启用渐变边缘
    var enableFadeEdge: Bool = true {
        didSet {
            if isScrolling {
                setupScrolling()
            } else {
                mask = enableFadeEdge ? nil : nil
            }
        }
    }
    
  override var contentsScale: CGFloat {
    didSet {
      textLayer.contentsScale = contentsScale
    }
  }
    
    // MARK: - 私有属性
    private let textLayer = CATextLayer()
    private var scrollAnimation: CAAnimation?
    private var isScrolling = false
    internal var textSize: CGSize = .zero
    
    // MARK: - 初始化
    
    override init() {
        super.init()
      setupTextLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    override init(layer: Any) {
//      super.init(layer: layer)
//      MainActor.assumeIsolated {
//        if let marqueeLayer = layer as? MarqueeTextLayer {
//          self.text = marqueeLayer.text
//          self.textColor = marqueeLayer.textColor
//          self.font = marqueeLayer.font
//          self.maxWidth = marqueeLayer.maxWidth
//          self.scrollSpeed = marqueeLayer.scrollSpeed
//          self.scrollInterval = marqueeLayer.scrollInterval
//          self.fadeEdgeWidth = marqueeLayer.fadeEdgeWidth
//          self.textAlignment = marqueeLayer.textAlignment
//          self.enableFadeEdge = marqueeLayer.enableFadeEdge
//        }
//        setupTextLayer()
//      }
//    }
    
    // MARK: - 设置
//  @MainActor
    private func setupTextLayer() {
        textLayer.alignmentMode = textAlignment
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.foregroundColor = textColor.cgColor
        textLayer.font = font
        textLayer.fontSize = font.pointSize
        textLayer.isWrapped = false
        textLayer.truncationMode = .none
        addSublayer(textLayer)
    }
    
    // MARK: - 文本显示更新
    
    private func updateTextDisplay() {
        guard !text.isEmpty else {
            textLayer.string = ""
            stopScrolling()
            return
        }
        
        // 计算文本实际尺寸
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        textSize = (text as NSString).size(withAttributes: attributes)
        
        textLayer.string = text
        
        // 判断是否需要滚动
        if textSize.width > maxWidth {
            // 需要滚动
            setupScrolling()
        } else {
            // 不需要滚动，按照对齐方式显示
            stopScrolling()
            positionTextForStaticDisplay()
        }
    }
    
    private func positionTextForStaticDisplay() {
        let x: CGFloat
        
        switch textAlignment {
        case .left, .natural:
            x = 0
        case .right:
            x = maxWidth - textSize.width
        case .center, .justified:
            x = (maxWidth - textSize.width) / 2
        default:
            x = (maxWidth - textSize.width) / 2
        }
        
        textLayer.frame = CGRect(x: x, y: 0, width: textSize.width, height: textSize.height)
        self.bounds = CGRect(x: 0, y: 0, width: maxWidth, height: textSize.height)
    }
    
    // MARK: - 滚动控制
    
    private func setupScrolling() {
        isScrolling = true
        
        // 设置文本层尺寸
        textLayer.frame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
        self.bounds = CGRect(x: 0, y: 0, width: maxWidth, height: textSize.height)
        
        // 设置渐变遮罩（如果启用）
        if enableFadeEdge {
            setupFadeMask()
        } else {
            mask = nil
        }
        
        // 开始滚动动画
        startScrollAnimation()
    }
    
    private func setupFadeMask() {
        let maskLayer = CAGradientLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: maxWidth, height: textSize.height)
        
        // 设置渐变方向：水平从左到右
        maskLayer.startPoint = CGPoint(x: 0, y: 0.5)
        maskLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        // 设置渐变颜色：两端透明，中间不透明
        let fadeRatio = min(fadeEdgeWidth / maxWidth, 0.4) // 限制最大渐变比例
        
        maskLayer.colors = [
            UIColor.clear.cgColor,           // 左侧完全透明
            UIColor.white.cgColor,           // 左侧渐变结束，完全不透明
            UIColor.white.cgColor,           // 中间区域完全不透明
            UIColor.clear.cgColor            // 右侧完全透明
        ]
        maskLayer.locations = [
            0.0,                                    // 左边界
            NSNumber(value: fadeRatio),             // 左侧渐变结束
            NSNumber(value: 1.0 - fadeRatio),       // 右侧渐变开始
            1.0                                     // 右边界
        ]
        
        mask = maskLayer
    }
    
    private func startScrollAnimation() {
        guard isScrolling && textSize.width > maxWidth else { return }
        
        // 停止之前的动画
        textLayer.removeAllAnimations()
        
        // 计算关键位置
        let totalScrollDistance = textSize.width + 20  // 文本宽度 + 间隙
        let duration = TimeInterval(totalScrollDistance / scrollSpeed)
        
        // 起始位置：文本完全在右侧外面（不可见）
        let startX = maxWidth + textSize.width / 2
        // 结束位置：文本完全在左侧外面（不可见）
        let endX = -textSize.width / 2
        
        // 设置文本层初始位置
        textLayer.position = CGPoint(x: startX, y: textSize.height / 2)
        
        // 创建位置动画
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = startX
        animation.toValue = endX
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + scrollInterval  // 延迟开始
        animation.autoreverses = false
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.isRemovedOnCompletion = false
        
        // 保存动画引用
        scrollAnimation = animation
        
        // 添加动画
        textLayer.add(animation, forKey: "marqueeScroll")
    }
    
    private func stopScrolling() {
        isScrolling = false
        textLayer.removeAllAnimations()
        scrollAnimation = nil
        mask = nil  // 移除mask
    }
    
    // MARK: - 公共控制方法
    
    /// 暂停滚动
    func pauseScrolling() {
        if isScrolling {
            textLayer.removeAllAnimations()
        }
    }
    
    /// 恢复滚动
    func resumeScrolling() {
        if isScrolling {
            startScrollAnimation()
        }
    }
    
    /// 重新开始滚动
    func restartScrolling() {
        if isScrolling {
            startScrollAnimation()
        } else {
            updateTextDisplay()
        }
    }
    
    /// 获取文本实际尺寸
    func calculateTextSize() -> CGSize {
        return textSize
    }
    
    /// 检查是否需要滚动
    func needsScrolling() -> Bool {
        return textSize.width > maxWidth
    }
}

// MARK: - 便利扩展

public extension MarqueeLabel {
    /// 流畅配置方法 - 设置文本
    /// - Parameter text: 文本内容
    /// - Returns: 自身实例，支持链式调用
    func text(_ text: String) -> Self {
        self.text = text
        return self
    }
    
    /// 流畅配置方法 - 设置文本颜色
    /// - Parameter color: 文本颜色
    /// - Returns: 自身实例，支持链式调用
    func textColor(_ color: UIColor) -> Self {
        config.textColor = color
        applyConfig()
        return self
    }
    
    /// 流畅配置方法 - 设置字体
    /// - Parameter font: 字体
    /// - Returns: 自身实例，支持链式调用
    func font(_ font: UIFont) -> Self {
        config.font = font
        applyConfig()
        return self
    }
    
    /// 流畅配置方法 - 设置最大宽度
    /// - Parameter width: 最大宽度
    /// - Returns: 自身实例，支持链式调用
    func maxWidth(_ width: CGFloat) -> Self {
        config.maxWidth = width
        applyConfig()
        return self
    }
    
    /// 流畅配置方法 - 设置滚动速度
    /// - Parameter speed: 滚动速度（点/秒）
    /// - Returns: 自身实例，支持链式调用
    func scrollSpeed(_ speed: CGFloat) -> Self {
        config.scrollSpeed = speed
        applyConfig()
        return self
    }
    
    /// 流畅配置方法 - 设置滚动延迟
    /// - Parameter delay: 延迟时间（秒）
    /// - Returns: 自身实例，支持链式调用
    func scrollDelay(_ delay: TimeInterval) -> Self {
        config.scrollDelay = delay
        applyConfig()
        return self
    }
}

// MARK: - 预设配置

public extension MarqueeLabelConfig {
    /// 默认配置
    static let `default` = MarqueeLabelConfig()
    
    /// 快速滚动配置
    static var fast: MarqueeLabelConfig {
        var config = MarqueeLabelConfig()
        config.scrollSpeed = 30
        config.scrollDelay = 0.5
        return config
    }
    
    /// 慢速滚动配置
    static var slow: MarqueeLabelConfig {
        var config = MarqueeLabelConfig()
        config.scrollSpeed = 8
        config.scrollDelay = 2.0
        return config
    }
    
    /// 大字体配置
    static var largeFont: MarqueeLabelConfig {
        var config = MarqueeLabelConfig()
        config.font = UIFont.boldSystemFont(ofSize: 16)
        config.maxWidth = 120
        return config
    }
    
    /// 小字体配置
    static var smallFont: MarqueeLabelConfig {
        var config = MarqueeLabelConfig()
        config.font = UIFont.systemFont(ofSize: 10)
        config.maxWidth = 80
        return config
    }
    
    /// 无渐变边缘配置
    static var noFadeEdge: MarqueeLabelConfig {
        var config = MarqueeLabelConfig()
        config.enableFadeEdge = false
        return config
    }
}
