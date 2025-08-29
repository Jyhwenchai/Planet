//
//  PlanetConfiguration.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  星球视图配置模型 - 统一管理外观、动画、交互等设置
//

import UIKit

// MARK: - 主配置结构体

/// 星球视图的完整配置
public struct PlanetConfiguration: Sendable {
    /// 外观配置
    public var appearance: AppearanceConfig = AppearanceConfig()
    
    /// 动画配置
    public var animation: AnimationConfig = AnimationConfig()
    
    /// 交互配置
    public var interaction: InteractionConfig = InteractionConfig()
    
    /// 性能配置
    public var performance: PerformanceConfig = PerformanceConfig()
    
    /// 布局配置
    public var layout: LayoutConfig = LayoutConfig()
    
    /// 公共初始化方法
    public init() {}
}

// MARK: - 外观配置

/// 星球外观相关配置
public struct AppearanceConfig: Sendable {
    /// 背景颜色
    public var backgroundColor: UIColor = .black
    
    /// 星球背景配置
    public var planetBackground: PlanetBackgroundConfig = PlanetBackgroundConfig()
    
    /// 标签外观配置
    public var labelStyle: LabelStyleConfig = LabelStyleConfig()
    
    /// 深度效果配置
    public var depthEffects: DepthEffectsConfig = DepthEffectsConfig()
    
    /// 公共初始化方法
    public init() {}
}

/// 星球背景配置
public struct PlanetBackgroundConfig: Sendable {
    /// 是否显示星球背景
    public var isVisible: Bool = false
    
    /// 星球背景类型
    public var backgroundType: PlanetBackgroundType = .gradient
    
    /// 渐变颜色（用于渐变背景）
    public var gradientColors: [UIColor] = [
        UIColor(white: 0.8, alpha: 0.3),
        UIColor(white: 0.4, alpha: 0.2),
        UIColor(white: 0.1, alpha: 0.1)
    ]
    
    /// 渐变位置
    public var gradientLocations: [Float] = [0.0, 0.7, 1.0]
    
    /// 渐变起始点（径向渐变）
    public var gradientStartPoint: CGPoint = CGPoint(x: 0.3, y: 0.3)
    
    /// 渐变结束点（径向渐变）
    public var gradientEndPoint: CGPoint = CGPoint(x: 1.0, y: 1.0)
    
    /// 纯色背景颜色
    public var solidColor: UIColor = UIColor(white: 0.2, alpha: 0.3)
    
    /// 背景图片
    public var backgroundImage: UIImage?
    
    /// 背景图片内容模式
    public var imageContentMode: UIView.ContentMode = .scaleAspectFill
    
    /// 公共初始化方法
    public init() {}
}

/// 星球背景类型
public enum PlanetBackgroundType: Sendable {
    case none           // 无背景
    case gradient       // 渐变背景
    case solid          // 纯色背景
    case image          // 图片背景
    case custom         // 自定义（用户提供CALayer）
}

/// 标签样式配置
public struct LabelStyleConfig: Sendable {
    /// 标签布局类型
    public var layoutType: LabelLayoutType = .textAboveCircle
    
    /// 文本配置
    public var textStyle: TextStyleConfig = TextStyleConfig()
    
    /// 圆圈配置
    public var circleStyle: CircleStyleConfig = CircleStyleConfig()
    
    /// 标签间距配置
    public var spacing: SpacingConfig = SpacingConfig()
    
    /// 默认标签颜色（当标签数据没有提供颜色时使用）
    public var defaultLabelColors: [UIColor] = [
        UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.9),   // 蓝色
        UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.9),   // 红色
        UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.9),   // 绿色
        UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.9),   // 橙色
        UIColor(red: 0.8, green: 0.2, blue: 0.8, alpha: 0.9),   // 紫色
        UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.9),   // 黄色
        UIColor(red: 0.4, green: 0.8, blue: 0.8, alpha: 0.9),   // 青色
        UIColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 0.9),   // 粉色
        UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.9),   // 淡紫色
        UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.9)    // 淡绿色
    ]
    
    /// 公共初始化方法
    public init() {}
}

/// 标签布局类型
public enum LabelLayoutType: Sendable {
    case textAboveCircle    // 文本在上，圆圈在下
    case textBelowCircle    // 文本在下，圆圈在上
    case textOnly           // 只显示文本
    case circleOnly         // 只显示圆圈
    case textLeftCircle     // 文本在左，圆圈在右
    case textRightCircle    // 文本在右，圆圈在左
}

/// 文本样式配置
public struct TextStyleConfig: Sendable {
    /// 字体
    public var font: UIFont = UIFont.boldSystemFont(ofSize: 12)
    
    /// 文本颜色
    public var color: UIColor = .white
    
    /// 最大文本宽度
    public var maxWidth: CGFloat = 80
    
    /// 跑马灯配置
    public var marqueeConfig: MarqueeLabelConfig = MarqueeLabelConfig()
    
    /// 是否启用跑马灯效果
    public var enableMarquee: Bool = true
    
    /// 文本阴影配置
    public var shadowConfig: TextShadowConfig?
    
    /// 公共初始化方法
    public init() {}
}

/// 文本阴影配置
public struct TextShadowConfig: Sendable {
    /// 阴影颜色
    public var color: UIColor = .black
    
    /// 阴影偏移
    public var offset: CGSize = CGSize(width: 1, height: 1)
    
    /// 阴影模糊半径
    public var blurRadius: CGFloat = 2
    
    /// 阴影透明度
    public var opacity: Float = 0.5
    
    /// 公共初始化方法
    public init() {}
}

/// 圆圈样式配置
public struct CircleStyleConfig: Sendable {
    /// 圆圈大小
    public var size: CGFloat = 16
    
    /// 圆圈边框宽度
    public var borderWidth: CGFloat = 0
    
    /// 圆圈边框颜色
    public var borderColor: UIColor = .white
    
    /// 是否使用渐变填充
    public var useGradientFill: Bool = false
    
    /// 渐变颜色（当useGradientFill为true时）
    public var gradientColors: [UIColor] = []
    
    /// 阴影配置
    public var shadowConfig: CircleShadowConfig?
    
    /// 公共初始化方法
    public init() {}
}

/// 圆圈阴影配置
public struct CircleShadowConfig: Sendable {
    /// 阴影颜色
    public var color: UIColor = .black
    
    /// 阴影偏移
    public var offset: CGSize = CGSize(width: 1, height: 1)
    
    /// 阴影半径
    public var radius: CGFloat = 2
    
    /// 阴影透明度
    public var opacity: Float = 0.3
    
    /// 公共初始化方法
    public init() {}
}

/// 间距配置
public struct SpacingConfig: Sendable {
    /// 文本与圆圈之间的间距
    public var textToCircle: CGFloat = 4
    
    /// 标签的内边距
    public var labelPadding: CGFloat = 4
    
    /// 点击区域的扩展边距
    public var hitTestPadding: CGFloat = 10
    
    /// 公共初始化方法
    public init() {}
}

/// 深度效果配置
public struct DepthEffectsConfig: Sendable {
    /// 是否启用背面剔除
    public var enableBackfaceCulling: Bool = false
    
    /// 深度透明度范围
    public var depthAlphaRange: ClosedRange<Float> = 0.3...1.0
    
    /// 深度缩放范围
    public var depthScaleRange: ClosedRange<Float> = 0.7...1.0
    
    /// 是否根据深度调整颜色
    public var enableDepthColorAdjustment: Bool = true
    
    /// 深度颜色调整强度
    public var depthColorIntensity: Float = 0.3
    
    /// 公共初始化方法
    public init() {}
}

// MARK: - 动画配置

/// 动画相关配置
public struct AnimationConfig: Sendable {
    /// 自动旋转配置
    public var autoRotation: AutoRotationConfig = AutoRotationConfig()
    
    /// 手势响应配置
    public var gestureResponse: GestureResponseConfig = GestureResponseConfig()
    
    /// 点击动画配置
    public var clickAnimation: ClickAnimationConfig = ClickAnimationConfig()
    
    /// 过渡动画配置
    public var transitions: TransitionConfig = TransitionConfig()
    
    /// 公共初始化方法
    public init() {}
}

/// 自动旋转配置
public struct AutoRotationConfig: Sendable {
    /// 是否启用自动旋转
    public var isEnabled: Bool = true
    
    /// 初始旋转轴
    public var initialAxis: Vector3 = Vector3(x: 0, y: 1, z: 0)
    
    /// 初始旋转速度（弧度/秒）
    public var initialSpeed: CGFloat = 0.005
    
    /// 旋转速度范围
    public var speedRange: ClosedRange<CGFloat> = 0.001...0.02
    
    /// 动画帧率
    public var frameRate: TimeInterval = 1.0/60.0
    
    /// 是否在手势后记住旋转方向
    public var rememberGestureDirection: Bool = true
    
    /// 公共初始化方法
    public init() {}
}

/// 手势响应配置
public struct GestureResponseConfig: Sendable {
    /// 旋转灵敏度
    public var rotationSensitivity: CGFloat = 0.01
    
    /// 惯性滚动配置
    public var inertia: InertiaConfig = InertiaConfig()
    
    /// 缩放配置
    public var scaling: ScalingConfig = ScalingConfig()
    
    /// 公共初始化方法
    public init() {}
}

/// 惯性滚动配置
public struct InertiaConfig: Sendable {
    /// 是否启用惯性滚动
    public var isEnabled: Bool = true
    
    /// 触发惯性滚动的最小速度
    public var minimumVelocity: CGFloat = 300
    
    /// 惯性衰减系数
    public var decayRate: CGFloat = 0.95
    
    /// 停止惯性的最小速度
    public var stopThreshold: CGFloat = 0.001
    
    /// 惯性动画帧率
    public var frameRate: TimeInterval = 1.0/60.0
    
    /// 公共初始化方法
    public init() {}
}

/// 缩放配置
public struct ScalingConfig: Sendable {
    /// 是否启用缩放
    public var isEnabled: Bool = true
    
    /// 缩放范围
    public var scaleRange: ClosedRange<CGFloat> = 0.3...3.0
    
    /// 默认缩放值
    public var defaultScale: CGFloat = 1.0
    
    /// 捏合手势灵敏度
    public var pinchSensitivity: CGFloat = 1.0
    
    /// 公共初始化方法
    public init() {}
}

/// 点击动画配置
public struct ClickAnimationConfig: Sendable {
    /// 是否启用点击动画
    public var isEnabled: Bool = true
    
    /// 缩放动画配置
    public var scaleAnimation: ScaleAnimationConfig = ScaleAnimationConfig()
    
    /// 颜色闪烁配置
    public var colorFlash: ColorFlashConfig = ColorFlashConfig()
    
    /// 震动反馈配置
    public var hapticFeedback: HapticFeedbackConfig = HapticFeedbackConfig()
    
    /// 公共初始化方法
    public init() {}
}

/// 缩放动画配置
public struct ScaleAnimationConfig: Sendable {
    /// 是否启用缩放动画
    public var isEnabled: Bool = true
    
    /// 最大缩放比例
    public var maxScale: CGFloat = 1.3
    
    /// 动画持续时间
    public var duration: TimeInterval = 0.2
    
    /// 动画时间函数
    public var timingFunction: CAMediaTimingFunctionName = .easeInEaseOut
    
    /// 公共初始化方法
    public init() {}
}

/// 颜色闪烁配置
public struct ColorFlashConfig: Sendable {
    /// 是否启用颜色闪烁
    public var isEnabled: Bool = true
    
    /// 闪烁颜色
    public var flashColor: UIColor = .white
    
    /// 动画持续时间
    public var duration: TimeInterval = 0.2
    
    /// 公共初始化方法
    public init() {}
}

/// 震动反馈配置
public struct HapticFeedbackConfig: Sendable {
    /// 是否启用震动反馈
    public var isEnabled: Bool = true
    
    /// 震动强度
    public var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    
    /// 公共初始化方法
    public init() {}
}

/// 过渡动画配置
public struct TransitionConfig: Sendable {
    /// 布局变化动画持续时间
    public var layoutDuration: TimeInterval = 0.3
    
    /// 数据更新动画持续时间
    public var dataUpdateDuration: TimeInterval = 0.5
    
    /// 动画曲线
    public var animationCurve: UIView.AnimationCurve = .easeInOut
    
    /// 公共初始化方法
    public init() {}
}

// MARK: - 交互配置

/// 交互相关配置
public struct InteractionConfig: Sendable {
    /// 是否启用手势交互
    public var isEnabled: Bool = true
    
    /// 支持的手势类型
    public var supportedGestures: Set<PlanetGestureType> = [.pan, .tap, .pinch]
    
    /// 点击检测配置
    public var hitTesting: HitTestingConfig = HitTestingConfig()
    
    /// 选择状态配置
    public var selection: SelectionConfig = SelectionConfig()
    
    /// 公共初始化方法
    public init() {}
}

/// 星球手势类型
public enum PlanetGestureType: CaseIterable, Hashable, Sendable {
    case pan        // 拖拽旋转
    case tap        // 点击
    case pinch      // 捏合缩放
    case doubleTap  // 双击
}

/// 点击检测配置
public struct HitTestingConfig: Sendable {
    /// 是否启用3D深度检测（选择最前面的标签）
    public var enable3DDepthTesting: Bool = true
    
    /// 点击区域扩展边距
    public var hitAreaExpansion: CGFloat = 10
    
    /// 最小点击区域大小
    public var minimumHitAreaSize: CGSize = CGSize(width: 44, height: 44)
    
    /// 公共初始化方法
    public init() {}
}

/// 选择状态配置
public struct SelectionConfig: Sendable {
    /// 是否支持选择状态
    public var isEnabled: Bool = false
    
    /// 是否支持多选
    public var allowsMultipleSelection: Bool = false
    
    /// 选中状态的视觉效果
    public var selectedAppearance: SelectedAppearanceConfig = SelectedAppearanceConfig()
    
    /// 公共初始化方法
    public init() {}
}

/// 选中状态外观配置
public struct SelectedAppearanceConfig: Sendable {
    /// 选中时的边框宽度
    public var borderWidth: CGFloat = 2
    
    /// 选中时的边框颜色
    public var borderColor: UIColor = .systemBlue
    
    /// 选中时的缩放比例
    public var scaleMultiplier: CGFloat = 1.1
    
    /// 选中时的透明度
    public var alpha: CGFloat = 1.0
    
    /// 选中状态动画持续时间
    public var animationDuration: TimeInterval = 0.2
    
    /// 公共初始化方法
    public init() {}
}

// MARK: - 性能配置

/// 性能相关配置
public struct PerformanceConfig: Sendable {
    /// 渲染优化配置
    public var rendering: RenderingConfig = RenderingConfig()
    
    /// 内存管理配置
    public var memory: MemoryConfig = MemoryConfig()
    
    /// 公共初始化方法
    public init() {}
}

/// 渲染优化配置
public struct RenderingConfig: Sendable {
    /// 是否启用异步渲染
    public var enableAsyncRendering: Bool = false
    
    /// 最大同时渲染的标签数量
    public var maxConcurrentRenders: Int = 10
    
    /// 是否启用视图回收
    public var enableViewRecycling: Bool = true
    
    /// 离屏渲染阈值
    public var offscreenRenderingThreshold: CGFloat = 100
    
    /// 公共初始化方法
    public init() {}
}

/// 内存管理配置
public struct MemoryConfig: Sendable {
    /// 最大缓存的标签视图数量
    public var maxCachedViews: Int = 50
    
    /// 内存警告时是否自动清理缓存
    public var autoClearOnMemoryWarning: Bool = true
    
    /// 缓存清理策略
    public var cacheEvictionPolicy: CacheEvictionPolicy = .leastRecentlyUsed
    
    /// 公共初始化方法
    public init() {}
}

/// 缓存回收策略
public enum CacheEvictionPolicy: Sendable {
    case leastRecentlyUsed  // 最少使用
    case firstInFirstOut    // 先进先出
    case random             // 随机
}

// MARK: - 布局配置

/// 布局相关配置
public struct LayoutConfig: Sendable {
    /// 星球半径的计算方式
    public var radiusCalculation: RadiusCalculationConfig = RadiusCalculationConfig()
    
    /// 标签分布配置
    public var distribution: DistributionConfig = DistributionConfig()
    
    /// 投影配置
    public var projection: ProjectionConfig = ProjectionConfig()
    
    /// 公共初始化方法
    public init() {}
}

/// 半径计算配置
public struct RadiusCalculationConfig: Sendable {
    /// 半径计算模式
    public var mode: RadiusMode = .proportionalToView
    
    /// 比例系数（当mode为proportionalToView时使用）
    public var proportionFactor: CGFloat = 0.4
    
    /// 固定半径值（当mode为fixed时使用）
    public var fixedRadius: CGFloat = 150
    
    /// 最小半径限制
    public var minimumRadius: CGFloat = 50
    
    /// 最大半径限制
    public var maximumRadius: CGFloat = 500
    
    /// 公共初始化方法
    public init() {}
}

/// 半径模式
public enum RadiusMode: Sendable {
    case proportionalToView    // 基于视图尺寸按比例计算
    case fixed                // 固定半径
    case adaptive             // 自适应（基于标签数量和内容）
}

/// 分布配置
public struct DistributionConfig: Sendable {
    /// 分布算法类型
    public var algorithm: DistributionAlgorithm = .fibonacci
    
    /// 自定义分布点（当algorithm为custom时使用）
    public var customPoints: [Vector3] = []
    
    /// 分布随机种子（用于reproducible随机分布）
    public var randomSeed: UInt32?
    
    /// 公共初始化方法
    public init() {}
}

/// 分布算法
public enum DistributionAlgorithm: Sendable {
    case fibonacci      // 斐波那契球面分布
    case random         // 随机分布
    case grid           // 网格分布
    case rings          // 环形分布
    case custom         // 自定义分布点
}

/// 投影配置
public struct ProjectionConfig: Sendable {
    /// 投影类型
    public var type: ProjectionType = .orthographic
    
    /// 透视投影的视场角（当type为perspective时使用）
    public var fieldOfView: CGFloat = 60
    
    /// 近裁剪平面
    public var nearClippingPlane: CGFloat = 0.1
    
    /// 远裁剪平面
    public var farClippingPlane: CGFloat = 1000
    
    /// 公共初始化方法
    public init() {}
}

/// 投影类型
public enum ProjectionType: Sendable {
    case orthographic   // 正交投影
    case perspective    // 透视投影
}

// MARK: - 预设配置

public extension PlanetConfiguration {
    /// 默认配置
    static let `default` = PlanetConfiguration()
    
    /// 最小配置（性能优先）
    static var minimal: PlanetConfiguration {
        var config = PlanetConfiguration()
        config.appearance.labelStyle.textStyle.enableMarquee = false
        config.animation.autoRotation.frameRate = 1.0/30.0
        config.animation.clickAnimation.isEnabled = false
        config.performance.rendering.enableViewRecycling = true
        config.performance.memory.maxCachedViews = 20
        return config
    }
    
    /// 豪华配置（效果优先）
    static var deluxe: PlanetConfiguration {
        var config = PlanetConfiguration()
        config.appearance.planetBackground.isVisible = true
        config.appearance.labelStyle.textStyle.shadowConfig = TextShadowConfig()
        config.appearance.labelStyle.circleStyle.shadowConfig = CircleShadowConfig()
        config.appearance.labelStyle.circleStyle.useGradientFill = true
        config.animation.clickAnimation.scaleAnimation.maxScale = 1.5
        config.interaction.selection.isEnabled = true
        return config
    }
    
    /// 高性能配置
    static var highPerformance: PlanetConfiguration {
        var config = PlanetConfiguration()
        config.animation.autoRotation.frameRate = 1.0/120.0
        config.animation.gestureResponse.inertia.frameRate = 1.0/120.0
        config.performance.rendering.enableAsyncRendering = true
        config.performance.rendering.maxConcurrentRenders = 20
        return config
    }
    
    /// 简约配置
    static var minimalist: PlanetConfiguration {
        var config = PlanetConfiguration()
        config.appearance.planetBackground.isVisible = false
        config.appearance.labelStyle.layoutType = .textOnly
        config.appearance.labelStyle.defaultLabelColors = [.white]
        config.animation.clickAnimation.colorFlash.isEnabled = false
        return config
    }
    
    /// 无交互配置（仅展示）
    static var displayOnly: PlanetConfiguration {
        var config = PlanetConfiguration()
        config.interaction.isEnabled = false
        config.animation.gestureResponse.inertia.isEnabled = false
        return config
    }
}
