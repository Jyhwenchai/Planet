//
//  PlanetLabelProtocols.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  核心标签协议定义
//

import UIKit

// MARK: - 核心协议

/// 星球标签基础协议 - 只需要实现标题
public protocol PlanetLabelRepresentable {
    /// 标签显示的主要文本
    var planetTitle: String { get }
}

/// 星球标签可自定义协议 - 提供更多自定义选项
public protocol PlanetLabelCustomizable: PlanetLabelRepresentable {
    /// 标签副标题（可选）
    var planetSubtitle: String? { get }
    
    /// 标签颜色（可选）
    var planetColor: UIColor? { get }
    
    /// 标签图标（可选）
    var planetIcon: UIImage? { get }
    
    /// 自定义数据（可选）- 用于存储额外信息
    var planetCustomData: [String: Any]? { get }
}

// MARK: - 默认实现

public extension PlanetLabelCustomizable {
    var planetSubtitle: String? { nil }
    var planetColor: UIColor? { nil }
    var planetIcon: UIImage? { nil }
    var planetCustomData: [String: Any]? { nil }
}

// MARK: - String 扩展支持

extension String: PlanetLabelRepresentable {
    public var planetTitle: String { self }
}

// MARK: - 内部标签数据包装器

/// 内部使用的标签数据包装器
internal struct PlanetLabelWrapper<T: PlanetLabelRepresentable> {
    let originalData: T
    let id: String
    let title: String
    let subtitle: String?
    let color: UIColor?
    let icon: UIImage?
    let customData: [String: Any]?
    
    init(_ data: T) {
        self.originalData = data
        self.id = UUID().uuidString
        self.title = data.planetTitle
        
        // 如果实现了自定义协议，提取额外信息
        if let customizable = data as? PlanetLabelCustomizable {
            self.subtitle = customizable.planetSubtitle
            self.color = customizable.planetColor
            self.icon = customizable.planetIcon
            self.customData = customizable.planetCustomData
        } else {
            self.subtitle = nil
            self.color = nil
            self.icon = nil
            self.customData = nil
        }
    }
}
