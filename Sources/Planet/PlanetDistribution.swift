//
//  PlanetDistribution.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  斐波那契球面分布算法 - 在球面上生成均匀分布的标签位置
//

import UIKit

// MARK: - 斐波那契球面分布

/// 斐波那契球面分布算法 - 产生最均匀的球面分布
public class PlanetDistribution {
    
    /// 使用斐波那契算法生成球面均匀分布点
    /// - Parameter count: 要生成的点数量
    /// - Returns: 标准化的3D位置点数组（每个点都在单位球面上）
    public static func generateFibonacciPoints(count: Int) -> [Vector3] {
        guard count > 0 else { return [] }
        
        var points: [Vector3] = []
        let goldenAngle: CGFloat = .pi * (3.0 - sqrt(5.0))  // 黄金角度 ≈ 2.618 弧度
        
        for i in 0..<count {
            // 斐波那契球面算法核心
            // y坐标：从1.0（北极）到-1.0（南极）均匀分布
            let y = 1.0 - (CGFloat(i) / CGFloat(count - 1)) * 2.0
            
            // 计算该纬度上的xy平面半径
            let radius = sqrt(1.0 - y * y)
            
            // 使用黄金角度确保最优分布
            let theta = goldenAngle * CGFloat(i)
            
            // 计算x,z坐标
            let x = cos(theta) * radius
            let z = sin(theta) * radius
            
            points.append(Vector3(x: x, y: y, z: z))
        }
        
        return points
    }
    
    /// 生成标签数据对应的分布点
    /// - Parameters:
    ///   - labelTitles: 标签标题数组
    ///   - colorPalette: 颜色调色板，如果为空则使用默认颜色
    /// - Returns: 包含位置和颜色信息的标签数据
    public static func generateLabelDistribution(
        for labelTitles: [String],
        colorPalette: [UIColor] = []
    ) -> [(position: Vector3, color: UIColor)] {
        
        let positions = generateFibonacciPoints(count: labelTitles.count)
        
        // 使用默认颜色如果没有提供调色板
        let colors = colorPalette.isEmpty ? defaultColorPalette : colorPalette
        
        var result: [(position: Vector3, color: UIColor)] = []
        
        for (index, position) in positions.enumerated() {
            let color = colors[index % colors.count]
            result.append((position: position, color: color))
        }
        
        return result
    }
    
    /// 默认颜色调色板
    private static let defaultColorPalette: [UIColor] = [
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
}

// MARK: - 分布质量验证

/// 分布质量验证工具
public extension PlanetDistribution {
    
    /// 验证分布质量 - 计算点之间的最小距离
    /// - Parameter points: 分布点数组
    /// - Returns: 最小点间距离
    static func validateDistribution(_ points: [Vector3]) -> CGFloat {
        guard points.count > 1 else { return 0 }
        
        var minDistance: CGFloat = .greatestFiniteMagnitude
        
        for i in 0..<points.count {
            for j in (i+1)..<points.count {
                let distance = points[i].subtract(points[j]).length
                minDistance = min(minDistance, distance)
            }
        }
        
        return minDistance
    }
    
    /// 计算理论最优最小距离（用于评估分布质量）
    /// - Parameter count: 点的数量
    /// - Returns: 理论最小距离
    static func theoreticalMinimumDistance(for count: Int) -> CGFloat {
        guard count > 1 else { return 0 }
        // 球面上N个点的理论最优最小距离的近似公式
        return 2.0 * sqrt(.pi / CGFloat(count))
    }
    
    /// 计算分布效率（0-1，越接近1越好）
    /// - Parameter points: 分布点数组
    /// - Returns: 分布效率
    static func calculateDistributionEfficiency(_ points: [Vector3]) -> CGFloat {
        guard points.count > 1 else { return 1.0 }
        
        let actualMinDistance = validateDistribution(points)
        let theoreticalMinDistance = theoreticalMinimumDistance(for: points.count)
        
        return min(1.0, actualMinDistance / theoreticalMinDistance)
    }
}
