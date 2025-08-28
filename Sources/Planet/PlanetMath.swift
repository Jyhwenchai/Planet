//
//  PlanetMath.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  3D数学工具模块 - 向量和四元数运算
//

import UIKit

// MARK: - 3D向量

/// 三维向量结构体，用于表示3D空间中的点和方向
public struct Vector3: Sendable {
    public let x, y, z: CGFloat
    
    // MARK: - 初始化
    
    /// 创建3D向量
    /// - Parameters:
    ///   - x: X坐标
    ///   - y: Y坐标  
    ///   - z: Z坐标
    public init(x: CGFloat, y: CGFloat, z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    // MARK: - 常用向量
    
    /// 零向量
    public static let zero = Vector3(x: 0, y: 0, z: 0)
    
    /// 单位向量 - X轴
    public static let unitX = Vector3(x: 1, y: 0, z: 0)
    
    /// 单位向量 - Y轴
    public static let unitY = Vector3(x: 0, y: 1, z: 0)
    
    /// 单位向量 - Z轴
    public static let unitZ = Vector3(x: 0, y: 0, z: 1)
    
    // MARK: - 向量运算
    
    /// 向量长度（模）
    public var length: CGFloat {
        return sqrt(x*x + y*y + z*z)
    }
    
    /// 向量长度的平方（避免开方运算，性能更好）
    public var lengthSquared: CGFloat {
        return x*x + y*y + z*z
    }
    
    /// 归一化向量（单位向量）
    /// - Returns: 长度为1的同方向向量
    public func normalized() -> Vector3 {
        let len = length
        guard len > 0.001 else { return Vector3.unitY } // 避免除零，返回默认向上方向
        return Vector3(x: x/len, y: y/len, z: z/len)
    }
    
    /// 向量加法
    /// - Parameter other: 另一个向量
    /// - Returns: 向量和
    public func add(_ other: Vector3) -> Vector3 {
        return Vector3(x: x + other.x, y: y + other.y, z: z + other.z)
    }
    
    /// 向量减法
    /// - Parameter other: 另一个向量
    /// - Returns: 向量差
    public func subtract(_ other: Vector3) -> Vector3 {
        return Vector3(x: x - other.x, y: y - other.y, z: z - other.z)
    }
    
    /// 向量数乘
    /// - Parameter scalar: 标量
    /// - Returns: 缩放后的向量
    public func multiply(by scalar: CGFloat) -> Vector3 {
        return Vector3(x: x * scalar, y: y * scalar, z: z * scalar)
    }
    
    /// 点积（内积）
    /// - Parameter other: 另一个向量
    /// - Returns: 点积结果
    public func dot(_ other: Vector3) -> CGFloat {
        return x * other.x + y * other.y + z * other.z
    }
    
    /// 叉积（外积）
    /// - Parameter other: 另一个向量
    /// - Returns: 叉积结果向量
    public func cross(_ other: Vector3) -> Vector3 {
        return Vector3(
            x: y * other.z - z * other.y,
            y: z * other.x - x * other.z,
            z: x * other.y - y * other.x
        )
    }
    
    /// 计算两向量间的角度（弧度）
    /// - Parameter other: 另一个向量
    /// - Returns: 角度（弧度）
    public func angleTo(_ other: Vector3) -> CGFloat {
        let denominator = sqrt(lengthSquared * other.lengthSquared)
        guard denominator > 0.001 else { return 0 }
        
        let cosAngle = max(-1.0, min(1.0, dot(other) / denominator))
        return acos(cosAngle)
    }
    
    /// 线性插值
    /// - Parameters:
    ///   - other: 目标向量
    ///   - t: 插值参数 (0.0 到 1.0)
    /// - Returns: 插值结果
    public func lerp(to other: Vector3, t: CGFloat) -> Vector3 {
        let clampedT = max(0.0, min(1.0, t))
        return Vector3(
            x: x + (other.x - x) * clampedT,
            y: y + (other.y - y) * clampedT,
            z: z + (other.z - z) * clampedT
        )
    }
}

// MARK: - Vector3 运算符重载

extension Vector3: Equatable {
    public static func == (lhs: Vector3, rhs: Vector3) -> Bool {
        return abs(lhs.x - rhs.x) < 0.001 && 
               abs(lhs.y - rhs.y) < 0.001 && 
               abs(lhs.z - rhs.z) < 0.001
    }
}

extension Vector3 {
    public static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return lhs.add(rhs)
    }
    
    public static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return lhs.subtract(rhs)
    }
    
    public static func * (lhs: Vector3, rhs: CGFloat) -> Vector3 {
        return lhs.multiply(by: rhs)
    }
    
    public static func * (lhs: CGFloat, rhs: Vector3) -> Vector3 {
        return rhs.multiply(by: lhs)
    }
}

// MARK: - 四元数

/// 四元数结构体，用于表示3D空间中的旋转
/// 四元数比欧拉角更适合3D旋转，避免万向锁问题且插值更平滑
public struct Quaternion: Sendable {
    public let w, x, y, z: CGFloat
    
    // MARK: - 初始化
    
    /// 直接从四个分量创建四元数
    /// - Parameters:
    ///   - w: 实部（标量部分）
    ///   - x: 虚部i系数
    ///   - y: 虚部j系数
    ///   - z: 虚部k系数
    public init(w: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat) {
        self.w = w
        self.x = x
        self.y = y
        self.z = z
    }
    
    /// 从旋转轴和角度创建四元数
    /// - Parameters:
    ///   - axis: 旋转轴（需要是单位向量）
    ///   - angle: 旋转角度（弧度）
    public init(axis: Vector3, angle: CGFloat) {
        let halfAngle = angle / 2.0
        let sinHalf = sin(halfAngle)
        let normalizedAxis = axis.normalized()
        
        w = cos(halfAngle)
        x = normalizedAxis.x * sinHalf
        y = normalizedAxis.y * sinHalf
        z = normalizedAxis.z * sinHalf
    }
    
    /// 从欧拉角创建四元数（XYZ顺序）
    /// - Parameters:
    ///   - pitch: X轴旋转角度（俯仰）
    ///   - yaw: Y轴旋转角度（偏航）
    ///   - roll: Z轴旋转角度（翻滚）
    public init(pitch: CGFloat, yaw: CGFloat, roll: CGFloat) {
        let halfPitch = pitch * 0.5
        let halfYaw = yaw * 0.5
        let halfRoll = roll * 0.5
        
        let cosPitch = cos(halfPitch)
        let sinPitch = sin(halfPitch)
        let cosYaw = cos(halfYaw)
        let sinYaw = sin(halfYaw)
        let cosRoll = cos(halfRoll)
        let sinRoll = sin(halfRoll)
        
        w = cosPitch * cosYaw * cosRoll + sinPitch * sinYaw * sinRoll
        x = sinPitch * cosYaw * cosRoll - cosPitch * sinYaw * sinRoll
        y = cosPitch * sinYaw * cosRoll + sinPitch * cosYaw * sinRoll
        z = cosPitch * cosYaw * sinRoll - sinPitch * sinYaw * cosRoll
    }
    
    // MARK: - 常用四元数
    
    /// 单位四元数（无旋转）
    public static let identity = Quaternion(w: 1, x: 0, y: 0, z: 0)
    
    // MARK: - 四元数运算
    
    /// 四元数长度（模）
    public var length: CGFloat {
        return sqrt(w*w + x*x + y*y + z*z)
    }
    
    /// 四元数长度的平方
    public var lengthSquared: CGFloat {
        return w*w + x*x + y*y + z*z
    }
    
    /// 归一化四元数
    /// - Returns: 长度为1的四元数
    public func normalized() -> Quaternion {
        let len = length
        guard len > 0.001 else { return Quaternion.identity }
        return Quaternion(w: w/len, x: x/len, y: y/len, z: z/len)
    }
    
    /// 四元数共轭
    /// - Returns: 共轭四元数
    public func conjugate() -> Quaternion {
        return Quaternion(w: w, x: -x, y: -y, z: -z)
    }
    
    /// 四元数逆
    /// - Returns: 逆四元数
    public func inverse() -> Quaternion {
        let lenSq = lengthSquared
        guard lenSq > 0.001 else { return Quaternion.identity }
        
        let invLenSq = 1.0 / lenSq
        let conj = conjugate()
        
        return Quaternion(
            w: conj.w * invLenSq,
            x: conj.x * invLenSq,
            y: conj.y * invLenSq,
            z: conj.z * invLenSq
        )
    }
    
    /// 四元数乘法（组合旋转）
    /// - Parameter other: 另一个四元数
    /// - Returns: 旋转组合结果
    public func multiply(_ other: Quaternion) -> Quaternion {
        return Quaternion(
            w: w * other.w - x * other.x - y * other.y - z * other.z,
            x: w * other.x + x * other.w + y * other.z - z * other.y,
            y: w * other.y - x * other.z + y * other.w + z * other.x,
            z: w * other.z + x * other.y - y * other.x + z * other.w
        )
    }
    
    /// 使用四元数旋转向量
    /// - Parameter vector: 要旋转的向量
    /// - Returns: 旋转后的向量
    public func rotate(vector: Vector3) -> Vector3 {
        // 将向量转换为纯四元数 (0, x, y, z)
        let vectorQuat = Quaternion(w: 0, x: vector.x, y: vector.y, z: vector.z)
        
        // 执行旋转: q * v * q*
        let result = self.multiply(vectorQuat).multiply(self.conjugate())
        
        return Vector3(x: result.x, y: result.y, z: result.z)
    }
    
    /// 球面线性插值 (SLERP)
    /// - Parameters:
    ///   - other: 目标四元数
    ///   - t: 插值参数 (0.0 到 1.0)
    /// - Returns: 插值结果
    public func slerp(to other: Quaternion, t: CGFloat) -> Quaternion {
        let clampedT = max(0.0, min(1.0, t))
        
        // 计算两四元数的点积
        var dot = w * other.w + x * other.x + y * other.y + z * other.z
        
        // 选择最短路径
        var otherQuat = other
        if dot < 0.0 {
            otherQuat = Quaternion(w: -other.w, x: -other.x, y: -other.y, z: -other.z)
            dot = -dot
        }
        
        // 如果夹角很小，使用线性插值
        if dot > 0.9995 {
            let result = Quaternion(
                w: w + (otherQuat.w - w) * clampedT,
                x: x + (otherQuat.x - x) * clampedT,
                y: y + (otherQuat.y - y) * clampedT,
                z: z + (otherQuat.z - z) * clampedT
            )
            return result.normalized()
        }
        
        // 球面线性插值
        let theta = acos(abs(dot))
        let sinTheta = sin(theta)
        
        let scale0 = sin((1.0 - clampedT) * theta) / sinTheta
        let scale1 = sin(clampedT * theta) / sinTheta
        
        return Quaternion(
            w: w * scale0 + otherQuat.w * scale1,
            x: x * scale0 + otherQuat.x * scale1,
            y: y * scale0 + otherQuat.y * scale1,
            z: z * scale0 + otherQuat.z * scale1
        )
    }
    
    /// 转换为欧拉角（XYZ顺序）
    /// - Returns: (pitch, yaw, roll) 元组
    public func toEulerAngles() -> (pitch: CGFloat, yaw: CGFloat, roll: CGFloat) {
        // 计算旋转矩阵元素
        let sinr_cosp = 2.0 * (w * x + y * z)
        let cosr_cosp = 1.0 - 2.0 * (x * x + y * y)
        let roll = atan2(sinr_cosp, cosr_cosp)
        
        let sinp = 2.0 * (w * y - z * x)
        let pitch = abs(sinp) >= 1.0 ? copysign(.pi / 2.0, sinp) : asin(sinp)
        
        let siny_cosp = 2.0 * (w * z + x * y)
        let cosy_cosp = 1.0 - 2.0 * (y * y + z * z)
        let yaw = atan2(siny_cosp, cosy_cosp)
        
        return (pitch: pitch, yaw: yaw, roll: roll)
    }
}

// MARK: - Quaternion 运算符重载

extension Quaternion: Equatable {
    public static func == (lhs: Quaternion, rhs: Quaternion) -> Bool {
        return abs(lhs.w - rhs.w) < 0.001 && 
               abs(lhs.x - rhs.x) < 0.001 && 
               abs(lhs.y - rhs.y) < 0.001 && 
               abs(lhs.z - rhs.z) < 0.001
    }
}

extension Quaternion {
    public static func * (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        return lhs.multiply(rhs)
    }
}

// MARK: - 数学工具函数

/// 数学工具类，提供常用的数学函数和常量
public enum PlanetMath {
    /// 度数转弧度
    /// - Parameter degrees: 角度值
    /// - Returns: 弧度值
    public static func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180.0
    }
    
    /// 弧度转度数
    /// - Parameter radians: 弧度值
    /// - Returns: 角度值
    public static func radiansToDegrees(_ radians: CGFloat) -> CGFloat {
        return radians * 180.0 / .pi
    }
    
    /// 限制数值在指定范围内
    /// - Parameters:
    ///   - value: 输入值
    ///   - min: 最小值
    ///   - max: 最大值
    /// - Returns: 限制后的值
    public static func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        return Swift.min(Swift.max(value, min), max)
    }
    
    /// 线性插值
    /// - Parameters:
    ///   - a: 起始值
    ///   - b: 结束值
    ///   - t: 插值参数 (0.0 到 1.0)
    /// - Returns: 插值结果
    public static func lerp(_ a: CGFloat, _ b: CGFloat, t: CGFloat) -> CGFloat {
        return a + (b - a) * clamp(t, min: 0.0, max: 1.0)
    }
    
    /// 平滑步插值（S型曲线）
    /// - Parameters:
    ///   - edge0: 下边界
    ///   - edge1: 上边界
    ///   - x: 输入值
    /// - Returns: 平滑插值结果
    public static func smoothstep(edge0: CGFloat, edge1: CGFloat, x: CGFloat) -> CGFloat {
        let t = clamp((x - edge0) / (edge1 - edge0), min: 0.0, max: 1.0)
        return t * t * (3.0 - 2.0 * t)
    }
}
