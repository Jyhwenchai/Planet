import Testing
@testable import Planet

// MARK: - 数学工具测试

@Test("Vector3 基本运算")
func vector3BasicOperations() {
    let v1 = Vector3(x: 1, y: 2, z: 3)
    let v2 = Vector3(x: 4, y: 5, z: 6)
    
    // 测试向量加法
    let sum = v1 + v2
    #expect(sum.x == 5)
    #expect(sum.y == 7) 
    #expect(sum.z == 9)
    
    // 测试向量长度
    let length = Vector3(x: 3, y: 4, z: 0).length
    #expect(abs(length - 5) < 0.001)
    
    // 测试归一化
    let normalized = Vector3(x: 3, y: 4, z: 0).normalized()
    #expect(abs(normalized.length - 1) < 0.001)
}

@Test("四元数旋转")
func quaternionRotation() {
    // 测试单位四元数
    let identity = Quaternion.identity
    let vector = Vector3(x: 1, y: 0, z: 0)
    let rotated = identity.rotate(vector: vector)
    
    #expect(abs(rotated.x - vector.x) < 0.001)
    #expect(abs(rotated.y - vector.y) < 0.001)
    #expect(abs(rotated.z - vector.z) < 0.001)
}

// MARK: - 分布算法测试

@Test("斐波那契分布")
func fibonacciDistribution() {
    let points = PlanetDistribution.generateFibonacciPoints(count: 10)
    
    // 验证点数正确
    #expect(points.count == 10)
    
    // 验证所有点都在单位球面上
    for point in points {
        #expect(abs(point.length - 1.0) < 0.001)
    }
    
    // 验证分布质量
    let efficiency = PlanetDistribution.calculateDistributionEfficiency(points)
    #expect(efficiency > 0.5) // 斐波那契分布应该有较高的效率
}

@Test("分布质量")
func distributionQuality() {
    let points5 = PlanetDistribution.generateFibonacciPoints(count: 5)
    let points20 = PlanetDistribution.generateFibonacciPoints(count: 20)
    let points100 = PlanetDistribution.generateFibonacciPoints(count: 100)
    
    // 验证分布质量随点数增加而提高  
    let efficiency5 = PlanetDistribution.calculateDistributionEfficiency(points5)
    let efficiency20 = PlanetDistribution.calculateDistributionEfficiency(points20)
    let efficiency100 = PlanetDistribution.calculateDistributionEfficiency(points100)
    
    #expect(efficiency5 <= efficiency20)
    #expect(efficiency20 <= efficiency100)
}

// MARK: - 配置测试

@Test("默认配置")
func planetConfigurationDefaults() {
    let config = PlanetConfiguration.default
    
    #expect(config.animation.autoRotation.isEnabled)
    #expect(config.interaction.isEnabled)
    #expect(config.appearance.backgroundColor == .black)
    #expect(config.layout.radiusCalculation.mode == .proportionalToView)
}

@Test("预设配置")
func presetConfigurations() {
    let minimal = PlanetConfiguration.minimal
    let deluxe = PlanetConfiguration.deluxe
    let highPerformance = PlanetConfiguration.highPerformance
    
    // 验证最小配置的特征
    #expect(!minimal.appearance.labelStyle.textStyle.enableMarquee)
    #expect(minimal.animation.autoRotation.frameRate == 1.0/30.0)
    
    // 验证豪华配置的特征
    #expect(deluxe.appearance.planetBackground.isVisible)
    #expect(deluxe.appearance.labelStyle.textStyle.shadowConfig != nil)
    
    // 验证高性能配置的特征
    #expect(highPerformance.animation.autoRotation.frameRate == 1.0/120.0)
    #expect(highPerformance.performance.rendering.enableAsyncRendering)
}

// MARK: - 协议测试

@Test("String协议支持")
func stringProtocolConformance() {
    let testString = "Test Label"
    #expect(testString.planetTitle == "Test Label")
}

@Test("自定义标签数据")
func customLabelData() {
    struct CustomLabel: PlanetLabelCustomizable {
        let planetTitle: String
        let planetSubtitle: String?
        let planetColor: UIColor?
        
        init(title: String, subtitle: String? = nil, color: UIColor? = nil) {
            self.planetTitle = title
            self.planetSubtitle = subtitle
            self.planetColor = color
        }
    }
    
    let label = CustomLabel(title: "Custom", subtitle: "Subtitle", color: .red)
    
    #expect(label.planetTitle == "Custom")
    #expect(label.planetSubtitle == "Subtitle")
    #expect(label.planetColor == .red)
}

// MARK: - 数学工具测试

@Test("数学工具函数")
func planetMathUtilities() {
    // 测试角度转换
    let degrees = PlanetMath.radiansToDegrees(.pi)
    #expect(abs(degrees - 180) < 0.001)
    
    let radians = PlanetMath.degreesToRadians(90)
    #expect(abs(radians - .pi / 2) < 0.001)
    
    // 测试钳制函数
    let clamped = PlanetMath.clamp(5.0, min: 0.0, max: 3.0)
    #expect(clamped == 3.0)
    
    // 测试线性插值
    let lerped = PlanetMath.lerp(0.0, 10.0, t: 0.5)
    #expect(abs(lerped - 5.0) < 0.001)
}

// MARK: - 边界条件测试

@Test("空标签")
func emptyLabels() {
    let emptyPoints = PlanetDistribution.generateFibonacciPoints(count: 0)
    #expect(emptyPoints.isEmpty)
}

@Test("单个标签")
func singleLabel() {
    let singlePoint = PlanetDistribution.generateFibonacciPoints(count: 1)
    #expect(singlePoint.count == 1)
    #expect(abs(singlePoint.first?.length ?? 0 - 1.0) < 0.001)
}

@Test("零向量")
func zeroVector() {
    let zero = Vector3.zero
    #expect(zero.length == 0)
    
    // 零向量的归一化应该返回默认向上方向
    let normalized = zero.normalized()
    #expect(normalized == Vector3.unitY)
}
