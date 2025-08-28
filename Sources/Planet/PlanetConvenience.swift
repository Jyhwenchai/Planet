//
//  PlanetConvenience.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  星球组件便利方法和链式API - 提供流畅的配置体验
//

import UIKit

// MARK: - 链式配置API

public extension PlanetView {
    
    /// 流畅配置方法 - 设置标签数据
    /// - Parameter labels: 标签数组
    /// - Returns: 自身实例，支持链式调用
    func labels(_ labels: [T]) -> Self {
        updateLabels(labels)
        return self
    }
    
    /// 流畅配置方法 - 设置背景颜色
    /// - Parameter color: 背景颜色
    /// - Returns: 自身实例，支持链式调用
    func backgroundColor(_ color: UIColor) -> Self {
        configuration.appearance.backgroundColor = color
        applyConfiguration()
        return self
    }
    
    /// 流畅配置方法 - 设置标签点击回调
    /// - Parameter handler: 点击事件处理器
    /// - Returns: 自身实例，支持链式调用
    func onTap(_ handler: @escaping LabelTapHandler<T>) -> Self {
        onLabelTap = handler
        return self
    }
    
    /// 流畅配置方法 - 设置标签长按回调
    /// - Parameter handler: 长按事件处理器
    /// - Returns: 自身实例，支持链式调用
    func onLongPress(_ handler: @escaping LabelLongPressHandler<T>) -> Self {
        onLabelLongPress = handler
        return self
    }
    
    /// 流畅配置方法 - 设置旋转状态回调
    /// - Parameter handler: 旋转状态处理器
    /// - Returns: 自身实例，支持链式调用
    func onRotationChanged(_ handler: @escaping RotationStateHandler) -> Self {
        onRotationChanged = handler
        return self
    }
    
    /// 流畅配置方法 - 设置缩放状态回调
    /// - Parameter handler: 缩放状态处理器
    /// - Returns: 自身实例，支持链式调用
    func onScaleChanged(_ handler: @escaping ScaleStateHandler) -> Self {
        onScaleChanged = handler
        return self
    }
    
    /// 流畅配置方法 - 应用预设配置
    /// - Parameter preset: 预设配置
    /// - Returns: 自身实例，支持链式调用
    func applyPreset(_ preset: PlanetConfiguration) -> Self {
        configuration = preset
        return self
    }
}

// MARK: - 外观配置便利方法

public extension PlanetView {
    
    /// 便利方法 - 设置标签文本样式
    /// - Parameters:
    ///   - font: 字体
    ///   - color: 颜色
    ///   - maxWidth: 最大宽度
    /// - Returns: 自身实例，支持链式调用
    func textStyle(font: UIFont, color: UIColor, maxWidth: CGFloat = 80) -> Self {
        configuration.appearance.labelStyle.textStyle.font = font
        configuration.appearance.labelStyle.textStyle.color = color
        configuration.appearance.labelStyle.textStyle.maxWidth = maxWidth
        applyConfiguration()
        return self
    }
    
    /// 便利方法 - 设置圆圈样式
    /// - Parameters:
    ///   - size: 圆圈大小
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    /// - Returns: 自身实例，支持链式调用
    func circleStyle(size: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = .white) -> Self {
        configuration.appearance.labelStyle.circleStyle.size = size
        configuration.appearance.labelStyle.circleStyle.borderWidth = borderWidth
        configuration.appearance.labelStyle.circleStyle.borderColor = borderColor
        applyConfiguration()
        return self
    }
    
    /// 便利方法 - 设置标签布局类型
    /// - Parameter layoutType: 布局类型
    /// - Returns: 自身实例，支持链式调用
    func labelLayout(_ layoutType: LabelLayoutType) -> Self {
        configuration.appearance.labelStyle.layoutType = layoutType
        applyConfiguration()
        return self
    }
    
    /// 便利方法 - 启用或禁用星球背景
    /// - Parameter enabled: 是否启用
    /// - Returns: 自身实例，支持链式调用
    func planetBackground(_ enabled: Bool) -> Self {
        configuration.appearance.planetBackground.isVisible = enabled
        applyConfiguration()
        return self
    }
    
    /// 便利方法 - 设置默认标签颜色
    /// - Parameter colors: 颜色数组
    /// - Returns: 自身实例，支持链式调用
    func defaultColors(_ colors: [UIColor]) -> Self {
        configuration.appearance.labelStyle.defaultLabelColors = colors
        applyConfiguration()
        return self
    }
}

// MARK: - 动画配置便利方法

public extension PlanetView {
    
    /// 便利方法 - 设置自动旋转
    /// - Parameters:
    ///   - enabled: 是否启用
    ///   - speed: 旋转速度
    ///   - axis: 旋转轴
    /// - Returns: 自身实例，支持链式调用
    func autoRotation(enabled: Bool, speed: CGFloat = 0.005, axis: Vector3 = Vector3.unitY) -> Self {
        configuration.animation.autoRotation.isEnabled = enabled
        configuration.animation.autoRotation.initialSpeed = speed
        configuration.animation.autoRotation.initialAxis = axis
        
        autoRotationSpeed = speed
        autoRotationAxis = axis
        
        if enabled && !isUserInteracting {
            startAutoRotationIfNeeded()
        } else {
            stopAutoRotation()
        }
        
        return self
    }
    
    /// 便利方法 - 设置手势灵敏度
    /// - Parameter sensitivity: 灵敏度系数
    /// - Returns: 自身实例，支持链式调用
    func rotationSensitivity(_ sensitivity: CGFloat) -> Self {
        configuration.animation.gestureResponse.rotationSensitivity = sensitivity
        return self
    }
    
    /// 便利方法 - 设置缩放范围
    /// - Parameter range: 缩放范围
    /// - Returns: 自身实例，支持链式调用
    func scaleRange(_ range: ClosedRange<CGFloat>) -> Self {
        configuration.animation.gestureResponse.scaling.scaleRange = range
        return self
    }
    
    /// 便利方法 - 启用或禁用惯性滚动
    /// - Parameter enabled: 是否启用
    /// - Returns: 自身实例，支持链式调用
    func inertiaScrolling(_ enabled: Bool) -> Self {
        configuration.animation.gestureResponse.inertia.isEnabled = enabled
        return self
    }
    
    /// 便利方法 - 启用或禁用点击动画
    /// - Parameter enabled: 是否启用
    /// - Returns: 自身实例，支持链式调用
    func clickAnimation(_ enabled: Bool) -> Self {
        configuration.animation.clickAnimation.isEnabled = enabled
        return self
    }
}

// MARK: - 交互配置便利方法

public extension PlanetView {
    
    /// 便利方法 - 设置支持的手势类型
    /// - Parameter gestures: 手势类型集合
    /// - Returns: 自身实例，支持链式调用
    func supportedGestures(_ gestures: Set<PlanetGestureType>) -> Self {
        configuration.interaction.supportedGestures = gestures
        setupGestures()
        return self
    }
    
    /// 便利方法 - 启用或禁用交互
    /// - Parameter enabled: 是否启用
    /// - Returns: 自身实例，支持链式调用
    func interactive(_ enabled: Bool) -> Self {
        configuration.interaction.isEnabled = enabled
        setupGestures()
        return self
    }
    
    /// 便利方法 - 设置点击检测配置
    /// - Parameters:
    ///   - enable3D: 是否启用3D深度检测
    ///   - hitPadding: 点击区域扩展边距
    /// - Returns: 自身实例，支持链式调用
    func hitTesting(enable3D: Bool = true, hitPadding: CGFloat = 10) -> Self {
        configuration.interaction.hitTesting.enable3DDepthTesting = enable3D
        configuration.interaction.hitTesting.hitAreaExpansion = hitPadding
        return self
    }
}

// MARK: - 性能配置便利方法

public extension PlanetView {
    
    /// 便利方法 - 设置性能模式
    /// - Parameter mode: 性能模式
    /// - Returns: 自身实例，支持链式调用
    func performanceMode(_ mode: PerformanceMode) -> Self {
        switch mode {
        case .lowPower:
            configuration.animation.autoRotation.frameRate = 1.0/30.0
            configuration.animation.gestureResponse.inertia.frameRate = 1.0/30.0
            configuration.performance.rendering.maxConcurrentRenders = 5
            
        case .balanced:
            configuration.animation.autoRotation.frameRate = 1.0/60.0
            configuration.animation.gestureResponse.inertia.frameRate = 1.0/60.0
            configuration.performance.rendering.maxConcurrentRenders = 10
            
        case .highPerformance:
            configuration.animation.autoRotation.frameRate = 1.0/120.0
            configuration.animation.gestureResponse.inertia.frameRate = 1.0/120.0
            configuration.performance.rendering.maxConcurrentRenders = 20
        }
        
        return self
    }
    
    /// 便利方法 - 启用或禁用视图回收
    /// - Parameter enabled: 是否启用
    /// - Returns: 自身实例，支持链式调用
    func viewRecycling(_ enabled: Bool) -> Self {
        configuration.performance.rendering.enableViewRecycling = enabled
        return self
    }
}

/// 性能模式枚举
public enum PerformanceMode {
    case lowPower        // 低功耗模式
    case balanced        // 平衡模式
    case highPerformance // 高性能模式
}

// MARK: - 便利工厂方法

public extension PlanetView {
    
    /// 创建简单的字符串标签星球
    /// - Parameters:
    ///   - labels: 字符串标签数组
    ///   - config: 配置选项
    /// - Returns: 配置好的星球视图
    static func withStringLabels(
        _ labels: [String],
        config: PlanetConfiguration = .default
    ) -> PlanetView<String> {
        let planetView = PlanetView<String>(configuration: config)
        planetView.updateLabels(labels)
        return planetView
    }
    
    /// 创建带预设主题的星球视图
    /// - Parameters:
    ///   - labels: 标签数组
    ///   - theme: 预设主题
    /// - Returns: 配置好的星球视图
    static func withTheme(_ labels: [T], theme: PlanetTheme) -> PlanetView<T> {
        let config = theme.toPlanetConfiguration()
        let planetView = PlanetView<T>(configuration: config)
        planetView.updateLabels(labels)
        return planetView
    }
}

// MARK: - 预设主题

/// 星球视图主题
public enum PlanetTheme {
    case `default`      // 默认主题
    case minimal        // 简约主题
    case colorful       // 彩色主题
    case dark           // 暗色主题
    case light          // 亮色主题
    case neon           // 霓虹主题
    case professional  // 专业主题
    
    /// 转换为配置
    /// - Returns: 对应的配置
    func toPlanetConfiguration() -> PlanetConfiguration {
        switch self {
        case .default:
            return .default
            
        case .minimal:
            return .minimalist
            
        case .colorful:
            var config = PlanetConfiguration.default
            config.appearance.labelStyle.defaultLabelColors = [
                UIColor.systemRed, UIColor.systemBlue, UIColor.systemGreen,
                UIColor.systemOrange, UIColor.systemPurple, UIColor.systemPink,
                UIColor.systemTeal, UIColor.systemYellow, UIColor.systemIndigo
            ]
            config.appearance.labelStyle.circleStyle.useGradientFill = true
            return config
            
        case .dark:
            var config = PlanetConfiguration.default
            config.appearance.backgroundColor = .black
            config.appearance.labelStyle.textStyle.color = .lightGray
            config.appearance.labelStyle.defaultLabelColors = [
                UIColor(white: 0.3, alpha: 0.8), UIColor(white: 0.4, alpha: 0.8),
                UIColor(white: 0.5, alpha: 0.8), UIColor(white: 0.6, alpha: 0.8)
            ]
            return config
            
        case .light:
            var config = PlanetConfiguration.default
            config.appearance.backgroundColor = .systemBackground
            config.appearance.labelStyle.textStyle.color = .label
            config.appearance.labelStyle.defaultLabelColors = [
                UIColor.systemBlue.withAlphaComponent(0.7),
                UIColor.systemGreen.withAlphaComponent(0.7),
                UIColor.systemOrange.withAlphaComponent(0.7),
                UIColor.systemPurple.withAlphaComponent(0.7)
            ]
            return config
            
        case .neon:
            var config = PlanetConfiguration.default
            config.appearance.backgroundColor = .black
            config.appearance.labelStyle.textStyle.color = .white
            config.appearance.labelStyle.defaultLabelColors = [
                UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.9),   // 青色霓虹
                UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.9),   // 洋红霓虹
                UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.9),   // 黄色霓虹
                UIColor(red: 0.5, green: 1.0, blue: 0.0, alpha: 0.9),   // 绿色霓虹
                UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.9)    // 橙色霓虹
            ]
            config.appearance.labelStyle.circleStyle.shadowConfig = CircleShadowConfig()
            return config
            
        case .professional:
            var config = PlanetConfiguration.default
            config.appearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
            config.appearance.labelStyle.textStyle.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            config.appearance.labelStyle.textStyle.color = UIColor(white: 0.9, alpha: 1.0)
            config.appearance.labelStyle.defaultLabelColors = [
                UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.8),
                UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 0.8),
                UIColor(red: 0.3, green: 0.5, blue: 0.85, alpha: 0.8)
            ]
            config.animation.clickAnimation.scaleAnimation.maxScale = 1.1
            return config
        }
    }
}

// MARK: - 配置构建器

/// 配置构建器 - 提供更直观的配置方式
public class PlanetConfigurationBuilder {
    
    private var config = PlanetConfiguration()
    
    public init() {}
    
    /// 设置外观
    /// - Parameter configurator: 外观配置闭包
    /// - Returns: 自身实例
    public func appearance(_ configurator: (inout AppearanceConfig) -> Void) -> Self {
        configurator(&config.appearance)
        return self
    }
    
    /// 设置动画
    /// - Parameter configurator: 动画配置闭包
    /// - Returns: 自身实例
    public func animation(_ configurator: (inout AnimationConfig) -> Void) -> Self {
        configurator(&config.animation)
        return self
    }
    
    /// 设置交互
    /// - Parameter configurator: 交互配置闭包
    /// - Returns: 自身实例
    public func interaction(_ configurator: (inout InteractionConfig) -> Void) -> Self {
        configurator(&config.interaction)
        return self
    }
    
    /// 设置性能
    /// - Parameter configurator: 性能配置闭包
    /// - Returns: 自身实例
    public func performance(_ configurator: (inout PerformanceConfig) -> Void) -> Self {
        configurator(&config.performance)
        return self
    }
    
    /// 设置布局
    /// - Parameter configurator: 布局配置闭包
    /// - Returns: 自身实例
    public func layout(_ configurator: (inout LayoutConfig) -> Void) -> Self {
        configurator(&config.layout)
        return self
    }
    
    /// 构建最终配置
    /// - Returns: 构建好的配置
    public func build() -> PlanetConfiguration {
        return config
    }
}

// MARK: - 便利初始化方法

public extension PlanetView where T == String {
    
    /// 便利初始化 - 直接使用字符串数组
    /// - Parameters:
    ///   - stringLabels: 字符串标签数组
    ///   - theme: 主题（可选）
    convenience init(stringLabels: [String], theme: PlanetTheme = .default) {
        self.init(configuration: theme.toPlanetConfiguration())
        updateLabels(stringLabels)
    }
}

// MARK: - 调试和分析工具

public extension PlanetView {
    
    /// 获取当前状态信息
    /// - Returns: 状态信息字典
    func getCurrentState() -> [String: Any] {
        let visibleCount = visibleLabelCount()
        let totalCount = labels.count
        
        return [
            "totalLabels": totalCount,
            "visibleLabels": visibleCount,
            "currentRotation": currentRotation,
            "currentScale": currentScale,
            "isInteracting": isCurrentlyInteracting(),
            "autoRotationEnabled": configuration.animation.autoRotation.isEnabled,
            "planetRadius": planetRadius
        ]
    }
    
    /// 打印当前状态（用于调试）
    func printCurrentState() {
        let state = getCurrentState()
        print("🌍 星球状态:")
        for (key, value) in state {
            print("  \(key): \(value)")
        }
    }
    
    /// 验证当前分布质量
    /// - Returns: 分布效率 (0-1)
    func validateDistributionQuality() -> CGFloat {
        let distributionPoints = PlanetDistribution.generateFibonacciPoints(count: labels.count)
        return PlanetDistribution.calculateDistributionEfficiency(distributionPoints)
    }
    
    /// 获取性能统计信息
    /// - Returns: 性能信息
    func getPerformanceStats() -> [String: Any] {
        return [
            "labelCount": labels.count,
            "visibleLabelCount": visibleLabelCount(),
            "currentFrameRate": configuration.animation.autoRotation.frameRate,
            "memoryUsage": "N/A", // 可以通过其他工具获取
            "recycledViewCount": "N/A"  // 内部管理器信息
        ]
    }
}

// MARK: - 便利操作方法

public extension PlanetView {
    
    /// 快速重置到默认状态
    func quickReset() {
        resetRotation()
        setScale(1.0)
        if configuration.animation.autoRotation.isEnabled {
            startAutoRotationIfNeeded()
        }
    }
    
    /// 暂停所有活动（用于应用进入后台时）
    func pauseAllActivity() {
        pauseAnimations()
        
        // 暂停所有跑马灯
//        for labelData in labelManager.labelData {
//            if let marqueeLayer = labelData.textLayer as? MarqueeTextLayer {
//                marqueeLayer.pauseScrolling()
//            }
//        }
    }
    
    /// 恢复所有活动（用于应用回到前台时）
    func resumeAllActivity() {
        resumeAnimations()
        
        // 恢复所有跑马灯
//        for labelData in labelManager.labelData {
//            if let marqueeLayer = labelData.textLayer as? MarqueeTextLayer {
//                marqueeLayer.resumeScrolling()
//            }
//        }
    }
    
    /// 查找并聚焦到第一个匹配的标签
    /// - Parameters:
    ///   - searchText: 搜索文本
    ///   - duration: 聚焦动画时长
    /// - Returns: 是否找到并聚焦了标签
    @discardableResult
    func searchAndFocus(_ searchText: String, duration: TimeInterval = 1.0) -> Bool {
        let matches = findLabels(containing: searchText)
        
        if let firstMatch = matches.first {
            focusOnLabel(at: firstMatch, duration: duration)
            return true
        }
        
        return false
    }
    
    /// 批量设置标签选择状态
    /// - Parameters:
    ///   - indices: 要选择的标签索引数组
    ///   - selected: 选择状态
    func setLabelSelection(indices: [Int], selected: Bool) {
        guard configuration.interaction.selection.isEnabled else { return }
        
        for index in indices {
            if let labelData = labelManager.labelData(at: index) {
                labelData.setSelected(selected)
                
                if let config = configuration.interaction.selection.selectedAppearance as SelectedAppearanceConfig? {
                    labelData.playSelectionAnimation(selected: selected, with: config)
                }
            }
        }
    }
    
    /// 获取所有选中标签的索引
    /// - Returns: 选中标签的索引数组
    func getSelectedIndices() -> [Int] {
        return labelManager.selectedLabelData().map { $0.index }
    }
}
