# Planet 🌍

一个强大、灵活的 iOS 星球视图组件，基于 2D CoreAnimation 技术实现 3D 交互效果。使用四元数数学和斐波那契球面分布算法，提供流畅的用户体验。

## ✨ 特性

- 🎯 **泛型设计**: 支持任意数据类型的标签（通过协议约束）
- 🎮 **流畅交互**: 基于四元数的 3D 旋转，支持拖拽、缩放、惯性滚动
- 🎨 **高度自定义**: 丰富的配置选项和预设主题
- 🚀 **优秀性能**: 内存回收、视图复用、异步渲染支持
- 📱 **现代Swift**: 使用 Swift 6+ 语言特性，支持链式 API
- 🎭 **跑马灯效果**: 内置跑马灯文本组件，支持长文本滚动

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
