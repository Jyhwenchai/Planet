# Planet 🌍

一个强大、灵活的 iOS 星球视图组件，基于 2D CoreAnimation 技术实现 3D 交互效果。使用四元数数学和斐波那契球面分布算法，配合 **CADisplayLink** 高性能动画引擎，提供流畅的用户体验。

## ✨ 特性

- 🎯 **泛型设计**: 支持任意数据类型的标签（通过协议约束）
- 🎮 **流畅交互**: 基于四元数的 3D 旋转，支持拖拽、缩放、惯性滚动
- 🚀 **高性能动画**: CADisplayLink 驱动的与屏幕刷新率同步的动画系统
- 🎨 **高度自定义**: 丰富的配置选项和预设主题
- ⚡ **优秀性能**: 内存回收、视图复用、异步渲染支持
- 📱 **现代Swift**: 使用 Swift 6+ 语言特性，支持链式 API
- 🎭 **跑马灯效果**: 内置跑马灯文本组件，支持长文本滚动
- 🎨 **丰富视觉效果**: 支持深度效果、阴影、渐变等

## 📦 安装

### Swift Package Manager

在 Xcode 中：
1. 选择 `File` → `Add Package Dependencies`
2. 输入仓库 URL
3. 选择版本范围

或在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/Planet", from: "1.0.0")
]
```

## 🚀 快速开始

### 基本用法

```swift
import Planet

// 1. 简单的字符串标签星球
let skills = ["Swift", "iOS", "UIKit", "CoreAnimation", "设计", "产品"]
let planetView = PlanetView.withStringLabels(skills)

view.addSubview(planetView)
planetView.frame = view.bounds

// 2. 添加点击事件
planetView.onTap { label, index in
    print("点击了: \(label)")
}
```

### 自定义数据类型

```swift
// 1. 定义你的数据模型
struct Skill: PlanetLabelCustomizable {
    let planetTitle: String
    let planetSubtitle: String?
    let planetColor: UIColor?
    let level: Int
    
    init(title: String, level: Int) {
        self.planetTitle = title
        self.planetSubtitle = "Level \(level)"
        self.planetColor = level > 5 ? .systemRed : .systemBlue
        self.level = level
    }
}

// 2. 创建星球视图
let skills = [
    Skill(title: "Swift开发", level: 8),
    Skill(title: "UI设计", level: 6),
    Skill(title: "产品策划", level: 7)
]

let planetView = PlanetView<Skill>()
    .labels(skills)
    .onTap { skill, index in
        print("技能: \(skill.planetTitle), 等级: \(skill.level)")
    }
```

### 链式配置 API

```swift
let planetView = PlanetView<String>()
    .labels(["Swift", "iOS", "Design"])
    .backgroundColor(.black)
    .textStyle(
        font: UIFont.boldSystemFont(ofSize: 14),
        color: .white,
        maxWidth: 100
    )
    .circleStyle(size: 20, borderWidth: 2, borderColor: .white)
    .autoRotation(enabled: true, speed: 0.008)
    .rotationSensitivity(0.015)
    .clickAnimation(true)
    .onTap { label, index in
        print("点击了: \(label)")
    }
```

## 🎨 主题和预设

### 预设主题

```swift
// 使用预设主题
let planetView = PlanetView.withTheme(labels, theme: .neon)
let planetView2 = PlanetView.withTheme(labels, theme: .professional)
let planetView3 = PlanetView.withTheme(labels, theme: .minimal)
```

### 自定义主题

```swift
let config = PlanetConfigurationBuilder()
    .appearance { appearance in
        appearance.backgroundColor = .systemIndigo
        appearance.labelStyle.textStyle.color = .white
        appearance.labelStyle.defaultLabelColors = [.systemPink, .systemTeal]
        appearance.planetBackground.isVisible = true
    }
    .animation { animation in
        animation.autoRotation.isEnabled = true
        animation.autoRotation.initialSpeed = 0.01
        animation.clickAnimation.scaleAnimation.maxScale = 1.5
    }
    .build()

let planetView = PlanetView<String>(configuration: config)
```

## 🎮 交互功能

### 手势支持

```swift
planetView.supportedGestures([.pan, .tap, .pinch, .longPress, .doubleTap])

// 配置各种事件
planetView
    .onTap { label, index in
        print("单击: \(label)")
    }
    .onLongPress { label, index in
        print("长按: \(label)")
    }
    .onRotationChanged { quaternion in
        print("旋转状态: \(quaternion)")
    }
    .onScaleChanged { scale in
        print("缩放: \(scale)")
    }
```

### 程序控制

```swift
// 旋转控制
planetView.resetRotation()
planetView.setRotation(Quaternion(axis: Vector3.unitY, angle: .pi/4))

// 缩放控制
planetView.setScale(1.5)

// 动画到指定状态
planetView.animateRotation(to: targetRotation, duration: 1.0)
planetView.animateScale(to: 2.0, duration: 0.5)

// 聚焦特定标签
planetView.focusOnLabel(at: 0, duration: 1.0)

// 搜索并聚焦
planetView.searchAndFocus("Swift")
```

## 🔧 高级配置

### 性能优化

```swift
planetView
    .performanceMode(.highPerformance)  // 高性能模式
    .viewRecycling(true)                // 启用视图回收
```

### 外观自定义

```swift
planetView
    .labelLayout(.textAboveCircle)      // 标签布局
    .planetBackground(true)             // 星球背景
    .defaultColors([.systemRed, .systemBlue]) // 默认颜色
```

### 动画控制

```swift
planetView
    .autoRotation(enabled: true, speed: 0.01, axis: Vector3(x: 1, y: 1, z: 0))
    .inertiaScrolling(true)
    .clickAnimation(true)
```

## 📚 API 文档

### 核心类

#### `PlanetView<T: PlanetLabelRepresentable>`

主要的星球视图组件。

**主要方法:**
- `updateLabels(_:)` - 更新标签数据
- `setRotation(_:)` - 设置旋转状态
- `setScale(_:)` - 设置缩放比例
- `focusOnLabel(at:duration:)` - 聚焦特定标签

#### `PlanetLabelRepresentable`

标签数据协议，只需实现 `planetTitle: String`。

#### `PlanetLabelCustomizable`

扩展标签协议，支持更多自定义选项：
- `planetSubtitle: String?` - 副标题
- `planetColor: UIColor?` - 自定义颜色
- `planetIcon: UIImage?` - 图标
- `planetCustomData: [String: Any]?` - 自定义数据

### 配置系统

#### `PlanetConfiguration`

主配置结构体，包含：
- `appearance` - 外观配置
- `animation` - 动画配置  
- `interaction` - 交互配置
- `performance` - 性能配置
- `layout` - 布局配置

---

## 🧩 配置详解（带默认值）

以下所有属性均可通过 PlanetConfiguration 或链式 API 配置。

- 外观 AppearanceConfig
  - backgroundColor: 视图背景色（默认 .black）
  - planetBackground: 星球背景配置 PlanetBackgroundConfig
    - isVisible: 是否显示（默认 false）
    - backgroundType: none | gradient | solid | image | custom（默认 gradient）
    - gradientColors: 渐变颜色数组（默认灰度渐变）
    - gradientLocations: 渐变位置（默认 [0.0, 0.7, 1.0]）
    - gradientStartPoint/gradientEndPoint: 渐变径向起止点（默认 (0.3,0.3)->(1,1)）
    - solidColor: 纯色（默认 20%灰）
    - backgroundImage: 背景图（默认 nil）
    - imageContentMode: 背景图模式（默认 .scaleAspectFill）
  - labelStyle: 标签样式 LabelStyleConfig
    - layoutType: textAboveCircle | textBelowCircle | textOnly | circleOnly | textLeftCircle | textRightCircle（默认 textAboveCircle）
    - textStyle: 文本样式 TextStyleConfig
      - font: 默认 bold 12
      - color: 默认 .white
      - maxWidth: 默认 80
      - enableMarquee: 是否启用跑马灯（默认 true）
      - marqueeConfig: MarqueeLabelConfig（详见源码）
      - shadowConfig: 文本阴影（可选）
    - circleStyle: 圆圈样式 CircleStyleConfig
      - size: 默认 16
      - borderWidth: 默认 0
      - borderColor: 默认 .white
      - useGradientFill: 渐变填充（默认 false）
      - gradientColors: 渐变颜色（默认 []）
      - shadowConfig: 圆圈阴影（可选）
    - spacing: 间距 SpacingConfig
      - textToCircle: 文本与圆圈间距（默认 4）
      - labelPadding: 标签内边距（默认 4）
      - hitTestPadding: 点击区域扩展（默认 10）
  - depthEffects: 深度效果 DepthEffectsConfig
    - enableBackfaceCulling: 背面剔除（默认 false）
    - depthAlphaRange: 0.3...1.0（默认）
    - depthScaleRange: 0.7...1.0（默认）
    - enableDepthColorAdjustment: 根据深度调整颜色（默认 true）
    - depthColorIntensity: 强度（默认 0.3）

- 动画 AnimationConfig
  - autoRotation: 自动旋转 AutoRotationConfig
    - isEnabled: 是否启用（默认 true）
    - initialAxis: 初始轴（默认 y 轴）
    - initialSpeed: 速度（弧度/秒，默认 0.005）
    - speedRange: 允许范围（默认 0.001...0.02）
    - frameRate: 逻辑帧率（默认 1/60；内部使用 CADisplayLink 同步渲染）
    - rememberGestureDirection: 手势后记忆方向（默认 true）
  - gestureResponse: 手势响应
    - rotationSensitivity: 旋转灵敏度（默认 0.01）
    - inertia: 惯性 InertiaConfig
      - isEnabled: 默认 true
      - minimumVelocity: 触发阈值（默认 300）
      - decayRate: 衰减系数（默认 0.95）
      - stopThreshold: 停止阈值（默认 0.001）
      - frameRate: 逻辑帧率（默认 1/60）
    - scaling: 缩放 ScalingConfig
      - isEnabled: 默认 true
      - scaleRange: 0.5...3.0（默认）
      - defaultScale: 默认 1.0
      - pinchSensitivity: 捏合灵敏度（默认 1.0）
  - clickAnimation: 点击动画 ClickAnimationConfig
    - isEnabled: 默认 true
    - scaleAnimation: ScaleAnimationConfig（maxScale 默认 1.3，duration 默认 0.2）
    - colorFlash: ColorFlashConfig（isEnabled 默认 true，flashColor 默认白色，duration 默认 0.2）
    - hapticFeedback: HapticFeedbackConfig（isEnabled 默认 true，impactStyle 默认 .medium）
  - transitions: 过渡动画 TransitionConfig
    - layoutDuration: 布局变化时长（默认 0.3）
    - dataUpdateDuration: 数据更新时长（默认 0.5）
    - animationCurve: 曲线（默认 .easeInOut）

- 交互 InteractionConfig
  - isEnabled: 是否启用交互（默认 true）
  - supportedGestures: 支持手势集合（默认 [.pan, .tap, .pinch]）
  - hitTesting: 点击检测 HitTestingConfig
    - enable3DDepthTesting: 3D 深度优先（默认 true）
    - hitAreaExpansion: 点击区域扩展（默认 10）
    - minimumHitAreaSize: 最小点选区域（默认 44x44）
  - selection: 选择 SelectionConfig
    - isEnabled: 是否可选（默认 false）
    - allowsMultipleSelection: 多选（默认 false）
    - selectedAppearance: 选中外观（边框/缩放/透明度/时长）

- 性能 PerformanceConfig
  - rendering: 渲染 RenderingConfig
    - enableAsyncRendering: 异步渲染（默认 false）
    - maxConcurrentRenders: 最大并发渲染（默认 10）
    - enableViewRecycling: 视图回收（默认 true）
    - offscreenRenderingThreshold: 离屏阈值（默认 100）
  - memory: 内存 MemoryConfig
    - maxCachedViews: 最大缓存视图数（默认 50）
    - autoClearOnMemoryWarning: 内存警告自动清理（默认 true）
    - cacheEvictionPolicy: LRU/FIFO/Random（默认 LRU）

- 布局 LayoutConfig
  - radiusCalculation: 半径计算 RadiusCalculationConfig
    - mode: proportionalToView | fixed | adaptive（默认 proportionalToView）
    - proportionFactor: 比例系数（默认 0.4）
    - fixedRadius: 固定半径（默认 150）
    - minimumRadius/maximumRadius: 半径上下限（默认 50/500）
  - distribution: 分布 DistributionConfig
    - algorithm: fibonacci | random | grid | rings | custom（默认 fibonacci）
    - customPoints: 自定义分布点
    - randomSeed: 随机种子（可复现）
  - projection: 投影 ProjectionConfig
    - type: orthographic | perspective（默认 orthographic）
    - fieldOfView: 透视 FOV（默认 60）
    - nearClippingPlane/farClippingPlane: 近远裁剪面（默认 0.1/1000）

---

## 🍳 常见配方（Recipes）

- 仅展示（无交互 + 自动旋转）
```swift
let view = PlanetView<String>()
    .labels(keywords)
    .interactive(false)
    .autoRotation(enabled: true, speed: 0.006)
```

- 数据较多时的高性能模式
```swift
let view = PlanetView<String>()
    .labels(manyTags)
    .performanceMode(.highPerformance)
    .textStyle(font: .systemFont(ofSize: 11, weight: .medium), color: .white)
    .planetBackground(false)
```

- 标签更突出：文本+圆圈、阴影与渐变
```swift
let view = PlanetView<String>()
    .labels(tags)
    .labelLayout(.textBelowCircle)
    .circleStyle(size: 18, borderWidth: 1, borderColor: .white)
    .defaultColors([.systemPink, .systemTeal, .systemYellow])
```

- 自定义旋转与聚焦
```swift
// 自定义旋转
let q = Quaternion(axis: Vector3.unitY, angle: .pi/3)
planetView.animateRotation(to: q, duration: 0.6)

// 聚焦第 3 个标签
planetView.focusOnLabel(at: 2, duration: 1.0)
```

- 搜索并聚焦
```swift
if planetView.searchAndFocus("swift") {
    print("已聚焦到第一个匹配项")
}
```

- 调整缩放范围与捏合灵敏度
```swift
planetView
    .scaleRange(0.8...2.0)
    .applyPreset(.highPerformance)
```

---

## 📝 重要变更

- v1.x: 将所有动画从 Timer 切换为 CADisplayLink，同步到屏幕刷新，显著减少掉帧与卡顿。
  - CADisplayLink selector 迁移至 PlanetView 主类（Swift 不允许泛型类扩展内的 @objc 方法）。
  - 新增统一动画状态：自动旋转、惯性滚动、自定义动画。
  - 手势交互与动画引擎整合，帧时间驱动，动画更平滑。

> 要求：iOS 13+，UIKit 环境（支持在 UIKit/SwiftUI 容器中使用）。

### 数学工具

#### `Vector3`

三维向量，支持：
- 基本运算（加减乘、点积、叉积）
- 长度计算和归一化
- 线性插值

#### `Quaternion`

四元数，用于 3D 旋转：
- 从轴角或欧拉角创建
- 四元数乘法和旋转
- 球面线性插值（SLERP）

## 🧪 示例项目

查看 `Examples/` 目录中的完整示例：

- **BasicExample** - 基本用法演示
- **CustomDataExample** - 自定义数据类型示例
- **ThemeShowcase** - 主题展示
- **AdvancedConfiguration** - 高级配置示例

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 基于斐波那契球面分布算法
- 灵感来源于 3D 数据可视化
- 感谢 CoreAnimation 和 UIKit 框架
