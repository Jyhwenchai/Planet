# WARP.md

本文件为 WARP (warp.dev) 在此代码库中工作提供指导。

## 项目概述

Planet 是一个强大、灵活的 iOS 3D 星球视图 Swift Package，基于 Swift 6+ 构建。它使用 CoreAnimation、四元数数学和斐波那契球面分布算法创建交互式 3D 球面标签可视化，通过 CADisplayLink 与屏幕刷新率同步，提供流畅的用户体验。

## 开发命令

### Swift Package 构建和测试

```bash
# 构建 Planet Swift Package
swift build

# 为 iPhone 16 Pro 模拟器架构构建
swift build -Xswiftc -sdk -Xswiftc "`xcrun --sdk iphonesimulator --show-sdk-path`" -Xswiftc -target -Xswiftc arm64-apple-ios13.0-simulator

# 运行所有 Package 测试
swift test

# 运行特定测试用例
swift test --filter "vector3BasicOperations"
swift test --filter "quaternionRotation" 
swift test --filter "fibonacciDistribution"
swift test --filter "planetConfigurationDefaults"

# 在 iPhone 16 Pro 模拟器环境下测试
swift test -Xswiftc -sdk -Xswiftc "`xcrun --sdk iphonesimulator --show-sdk-path`" -Xswiftc -target -Xswiftc arm64-apple-ios13.0-simulator

# 生成 Swift Package 文档
swift package generate-documentation

# 检查 Package 依赖
swift package show-dependencies

# 解析 Package 依赖
swift package resolve

# 清理构建产物
swift package clean
```

### iPhone 16 Pro 模拟器相关命令

```bash
# 检查 iPhone 16 Pro 模拟器状态
xcrun simctl list devices available | grep "iPhone 16 Pro"

# 启动 iPhone 16 Pro 模拟器（如果需要）
xcrun simctl boot "iPhone 16 Pro"

# 验证模拟器支持的 iOS 版本（Planet 需要 iOS 13+）
xcrun simctl list runtimes | grep iOS
```

### 示例项目（可选，用于验证 Package 功能）

```bash
# 在 iPhone 16 Pro 模拟器上构建示例项目
cd Example && xcodebuild -project Example.xcodeproj -scheme Example -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# 在 iPhone 16 Pro 模拟器上运行示例项目
cd Example && xcodebuild -project Example.xcodeproj -scheme Example -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test

# 在 Xcode 中打开示例项目（验证 Package 集成）
open Example/Example.xcodeproj
```

### 代码质量和验证

```bash
# 格式化代码（如果安装了 swift-format）
swift-format --in-place --recursive Sources/ Tests/

# 代码检查（如果配置了 SwiftLint）
swiftlint

# Package 内置的性能基准测试
swift test --filter "benchmarkDistribution"

# 验证数学组件正确性
swift test --filter "validateMathComponents"

# 内存使用分析
swift test --filter "analyzeMemoryUsage"
```

## Swift Package 架构

### Package 结构
```
Planet/
├── Package.swift                 # Package 清单文件
├── Sources/Planet/              # 主要源代码
│   ├── Planet.swift            # 主入口，版本信息，全局函数
│   ├── PlanetView.swift        # 核心视图组件
│   ├── PlanetConfiguration.swift # 配置系统
│   ├── PlanetMath.swift        # 数学工具（Vector3, Quaternion）
│   ├── PlanetDistribution.swift # 分布算法
│   ├── PlanetInteraction.swift # 交互处理
│   ├── PlanetConvenience.swift # 链式 API
│   ├── PlanetLabelProtocols.swift # 协议定义
│   ├── PlanetLabelData.swift   # 标签数据管理
│   └── MarqueeLabel.swift      # 跑马灯组件
├── Tests/PlanetTests/          # 测试代码
│   └── PlanetTests.swift
└── Example/                    # 示例项目（展示用法）
```

### 核心组件（Swift Package）

**主要模块:**
- **PlanetView<T>**: 支持任何 `PlanetLabelRepresentable` 数据的泛型主组件
- **PlanetConfiguration**: 综合配置系统（外观、动画、交互、性能、布局）
- **数学引擎**: Vector3 和 Quaternion 结构体用于 3D 变换
- **分布引擎**: 斐波那契球面算法用于优化点分布
- **动画引擎**: 基于 CADisplayLink 的系统，与屏幕刷新同步

### Package 依赖和要求

```swift
// Package.swift 配置
platforms: [
    .iOS(.v13)  // 支持 iOS 13+，兼容 iPhone 16 Pro
],
dependencies: [
    // 无外部依赖，纯原生实现
],
swiftLanguageVersions: [.v6]  // 使用 Swift 6
```

### iPhone 16 Pro 优化特性

Package 专门为现代 iOS 设备（包括 iPhone 16 Pro）优化：

```swift
// ProMotion 120Hz 支持
public static var highPerformance: PlanetConfiguration {
    var config = PlanetConfiguration()
    config.animation.autoRotation.frameRate = 1.0/120.0  // 120fps
    config.animation.gestureResponse.inertia.frameRate = 1.0/120.0
    config.performance.rendering.enableAsyncRendering = true
    config.performance.rendering.maxConcurrentRenders = 20
    return config
}
```

## Package 集成使用

### 在其他项目中集成 Planet Package

```swift
// Package.swift 中添加依赖
dependencies: [
    .package(url: "https://github.com/your-repo/Planet", from: "1.0.0")
]

// 在代码中使用
import Planet

let planetView = PlanetView<String>()
    .labels(["Swift", "iOS", "设计"])
    .applyPreset(.highPerformance)  // iPhone 16 Pro 优化
    .onTap { label, index in 
        print("点击了: \(label)") 
    }
```

### 基本 API（Package 提供）

```swift
// 全局便利函数
let planetView = makePlanet(with: ["标签1", "标签2", "标签3"])
let themedPlanet = makePlanet(with: labels, theme: .deluxe)

// 链式配置 API
let customPlanet = PlanetView<CustomData>()
    .labels(customDataArray)
    .backgroundColor(.black)
    .textStyle(font: .boldSystemFont(ofSize: 14), color: .white)
    .autoRotation(enabled: true, speed: 0.008)
    .planetBackground(true)

// 调试和分析工具
Planet.debug.printVersionInfo()
let isValid = Planet.debug.validateMathComponents()
let performance = Planet.debug.benchmarkDistribution()
```

## 开发 Package 的最佳实践

### 添加新功能到 Package
1. **修改配置**: 在 `PlanetConfiguration.swift` 中添加新的配置选项
2. **实现核心逻辑**: 在相应的核心文件中实现功能
3. **添加便利方法**: 在 `PlanetConvenience.swift` 中添加链式 API
4. **编写测试**: 在 `Tests/PlanetTests/` 中添加测试用例
5. **更新示例**: 在 `Example/` 项目中展示新功能用法
6. **运行完整测试**: `swift test` 验证所有功能正常

### Package 性能优化
```bash
# 性能分析（Package 内置工具）
swift test --filter "benchmarkDistribution"

# 内存使用分析
swift test --filter "analyzeMemoryUsage" 

# 验证数学组件正确性
swift test --filter "validateMathComponents"
```

### iPhone 16 Pro 特定测试
```bash
# 在 iPhone 16 Pro 模拟器架构下运行测试
swift test -Xswiftc -sdk -Xswiftc "`xcrun --sdk iphonesimulator --show-sdk-path`" -Xswiftc -target -Xswiftc arm64-apple-ios13.0-simulator

# 测试高性能配置
swift test --filter "highPerformanceConfiguration"

# ProMotion 相关测试
swift test --filter "animationFrameRate"
```

## 故障排除

### Package 构建问题
```bash
# 清理并重新构建
swift package clean
swift build

# 重新解析依赖
swift package resolve

# 检查 Package 有效性
swift package dump-package
```

### iPhone 16 Pro 模拟器相关问题
```bash
# 如果模拟器构建失败，检查 SDK 路径
xcrun --sdk iphonesimulator --show-sdk-path

# 验证支持的架构
xcrun simctl list devicetypes | grep "iPhone 16 Pro"

# 重新启动模拟器
xcrun simctl shutdown "iPhone 16 Pro" && xcrun simctl boot "iPhone 16 Pro"
```

这个 Swift Package 专门为现代 iOS 设备（包括 iPhone 16 Pro）设计，提供高性能的 3D 标签可视化功能。
