//
//  Planet.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  Planet Swift Package 主接口 - 导出所有公开API
//

import UIKit

// MARK: - 版本信息

/// Planet 组件库版本信息
public struct PlanetVersion {
    /// 主版本号
    public static let major = 1
    
    /// 次版本号
    public static let minor = 0
    
    /// 修订版本号
    public static let patch = 0
    
    /// 完整版本字符串
    public static let versionString = "\(major).\(minor).\(patch)"
    
    /// 构建信息
    public static let buildInfo = "Built with Swift 6+"
}

// MARK: - 全局便利函数

/// 创建默认的字符串星球视图
/// - Parameter labels: 字符串标签数组
/// - Returns: 配置好的星球视图
@MainActor public func makePlanet(with labels: [String]) -> PlanetView<String> {
    return PlanetView<String>.withStringLabels(labels)
}

/// 创建带主题的字符串星球视图
/// - Parameters:
///   - labels: 字符串标签数组
///   - theme: 主题
/// - Returns: 配置好的星球视图
@MainActor public func makePlanet(with labels: [String], theme: PlanetTheme) -> PlanetView<String> {
    return PlanetView<String>.withTheme(labels, theme: theme)
}

/// 创建自定义数据类型的星球视图
/// - Parameters:
///   - labels: 标签数组
///   - configuration: 配置选项
/// - Returns: 配置好的星球视图
@MainActor public func makePlanet<T: PlanetLabelRepresentable>(
    with labels: [T], 
    configuration: PlanetConfiguration = .default
) -> PlanetView<T> {
    return PlanetView<T>(configuration: configuration).labels(labels)
}

// MARK: - 调试工具

/// Planet 组件库调试信息
public struct PlanetDebug {
    
    /// 打印版本信息
    public static func printVersionInfo() {
        print("🌍 Planet Swift Package")
        print("   Version: \(PlanetVersion.versionString)")
        print("   \(PlanetVersion.buildInfo)")
    }
    
    /// 验证数学工具正确性
    /// - Returns: 是否通过验证
    public static func validateMathComponents() -> Bool {
        // 验证Vector3
        let v1 = Vector3(x: 1, y: 0, z: 0)
        let v2 = Vector3(x: 0, y: 1, z: 0)
        let cross = v1.cross(v2)
        
        guard abs(cross.z - 1.0) < 0.001 else {
            print("❌ Vector3 叉积计算错误")
            return false
        }
        
        // 验证Quaternion
        let rotation = Quaternion(axis: Vector3.unitY, angle: .pi / 2)
        let rotated = rotation.rotate(vector: v1)
        
        guard abs(rotated.z + 1.0) < 0.001 else {
            print("❌ Quaternion 旋转计算错误")
            return false
        }
        
        // 验证分布算法
        let points = PlanetDistribution.generateFibonacciPoints(count: 10)
        guard points.count == 10 else {
            print("❌ 分布算法错误")
            return false
        }
        
        for point in points {
            guard abs(point.length - 1.0) < 0.001 else {
                print("❌ 分布点不在单位球面上")
                return false
            }
        }
        
        print("✅ 所有数学组件验证通过")
        return true
    }
    
    /// 基准测试 - 测试1000个点的分布算法性能
    /// - Returns: 执行时间（秒）
    public static func benchmarkDistribution() -> TimeInterval {
        let startTime = CACurrentMediaTime()
        
        for _ in 0..<10 {
            let _ = PlanetDistribution.generateFibonacciPoints(count: 1000)
        }
        
        let endTime = CACurrentMediaTime()
        let duration = endTime - startTime
        
        print("📊 分布算法基准测试:")
        print("   10次生成1000个点耗时: \(String(format: "%.4f", duration))秒")
        print("   平均每次耗时: \(String(format: "%.4f", duration/10))秒")
        
        return duration
    }
    
    /// 内存使用情况分析
    /// - Parameter labelCount: 标签数量
    /// - Returns: 分析结果
    @MainActor public static func analyzeMemoryUsage(for labelCount: Int) -> [String: Any] {
        // 创建测试数据
        let labels = (0..<labelCount).map { "Label \($0)" }
        let planetView = PlanetView<String>.withStringLabels(labels)
        
        // 计算大概的内存使用量
        let vectorSize = MemoryLayout<Vector3>.size
        let quaternionSize = MemoryLayout<Quaternion>.size
        let stringSize = labels.reduce(0) { $0 + $1.utf8.count }
        
        let estimatedMemory = vectorSize * labelCount + // 位置向量
                            quaternionSize + // 当前旋转
                            stringSize + // 字符串内容
                            labelCount * 200 // 估算的UI层内存
        
        let analysis = [
            "labelCount": labelCount,
            "estimatedMemoryBytes": estimatedMemory,
            "estimatedMemoryKB": estimatedMemory / 1024,
            "distributionEfficiency": planetView.validateDistributionQuality()
        ] as [String: Any]
        
        print("💾 内存使用分析:")
        for (key, value) in analysis {
            print("   \(key): \(value)")
        }
        
        return analysis
    }
}

// MARK: - 示例生成器

/// 示例数据生成器
public struct PlanetExamples {
    
    /// 生成技能标签示例
    /// - Returns: 技能标签数组
    public static func skillLabels() -> [String] {
        return [
            "Swift开发", "iOS应用", "UI设计", "UX设计", "产品策划",
            "项目管理", "团队协作", "数据分析", "用户研究", "市场推广",
            "品牌设计", "前端开发", "后端开发", "数据库", "API设计",
            "测试", "DevOps", "云服务", "机器学习", "算法优化"
        ]
    }
    
    /// 生成编程语言示例
    /// - Returns: 编程语言标签数组
    public static func programmingLanguages() -> [String] {
        return [
            "Swift", "Objective-C", "Python", "JavaScript", "TypeScript",
            "Java", "Kotlin", "Dart", "Go", "Rust", "C++", "C#", "Ruby", "PHP"
        ]
    }
    
    /// 生成自定义技能数据
    /// - Returns: 自定义技能数组
    public static func customSkills() -> [CustomSkill] {
        return [
            CustomSkill(name: "Swift开发", level: 9, category: .programming),
            CustomSkill(name: "UI设计", level: 8, category: .design),
            CustomSkill(name: "产品策划", level: 7, category: .product),
            CustomSkill(name: "团队管理", level: 6, category: .management),
            CustomSkill(name: "数据分析", level: 8, category: .analytics),
            CustomSkill(name: "用户研究", level: 7, category: .research)
        ]
    }
    
    /// 示例自定义技能数据类型
    public struct CustomSkill: PlanetLabelCustomizable {
        public let planetTitle: String
        public let planetSubtitle: String?
        public let planetColor: UIColor?
        public let planetIcon: UIImage?
        
        let level: Int
        let category: SkillCategory
        
        public init(name: String, level: Int, category: SkillCategory) {
            self.planetTitle = name
            self.planetSubtitle = "Level \(level)"
            self.level = level
            self.category = category
            
            // 根据等级设置颜色
            if level >= 8 {
                self.planetColor = UIColor.systemRed
            } else if level >= 6 {
                self.planetColor = UIColor.systemOrange  
            } else {
                self.planetColor = UIColor.systemBlue
            }
            
            // 根据类别设置图标（这里简化处理）
            self.planetIcon = nil
        }
        
        public enum SkillCategory {
            case programming, design, product, management, analytics, research
        }
    }
}

/// Planet 组件全局命名空间
public enum Planet {
    /// 版本信息
    public static let version = PlanetVersion.self
    
    /// 调试工具
    public static let debug = PlanetDebug.self
    
    /// 示例数据
    public static let examples = PlanetExamples.self
}
