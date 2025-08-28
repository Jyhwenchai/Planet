//
//  CityDataViewController.swift
//  Example
//
//  Created by didong on 2025/8/28.
//  世界主要城市数据展示
//

import UIKit
import Planet

class CityDataViewController: UIViewController {
    
    private var planetView: PlanetView<CityData>!
    private let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlanetView()
        loadCityData()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0) // 深蓝夜空色
        
        // 状态标签
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "🌍 世界主要城市"
        statusLabel.textColor = .white
        statusLabel.font = UIFont.boldSystemFont(ofSize: 18)
        statusLabel.textAlignment = .center
        
        // 创建星球视图
        planetView = PlanetView<CityData>(configuration: createCustomConfiguration())
        planetView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(statusLabel)
        view.addSubview(planetView)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            planetView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            planetView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            planetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            planetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            planetView.heightAnchor.constraint(equalTo: planetView.widthAnchor)
        ])
    }
    
    private func createCustomConfiguration() -> PlanetConfiguration {
        var config = PlanetConfiguration.default
        
        // 背景设置
        config.appearance.planetBackground.isVisible = true
        config.appearance.planetBackground.backgroundType = .gradient
        config.appearance.planetBackground.gradientColors = [
            UIColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 0.8),
            UIColor(red: 0.0, green: 0.1, blue: 0.4, alpha: 0.6)
        ]
        
        // 标签样式
        config.appearance.labelStyle.textStyle.color = .white
        config.appearance.labelStyle.textStyle.font = UIFont.boldSystemFont(ofSize: 14)
        config.appearance.labelStyle.circleStyle.size = 8
        config.appearance.labelStyle.layoutType = .textAboveCircle
        
        // 动画设置
        config.animation.autoRotation.isEnabled = true
        config.animation.autoRotation.initialSpeed = 0.008
        
        return config
    }
    
    private func setupPlanetView() {
        // 设置事件回调
        planetView.onLabelTap = { [weak self] city, index in
            self?.showCityInfo(city)
        }
        
        planetView.onRotationChanged = { [weak self] rotation in
            // 可以在这里更新UI或处理旋转事件
        }
    }
    
    private func loadCityData() {
        let cities = [
            CityData(name: "北京", country: "中国", population: "2152万", color: .red),
            CityData(name: "东京", country: "日本", population: "1395万", color: .systemPink),
            CityData(name: "纽约", country: "美国", population: "847万", color: .blue),
            CityData(name: "伦敦", country: "英国", population: "898万", color: .green),
            CityData(name: "巴黎", country: "法国", population: "1085万", color: .purple),
            CityData(name: "莫斯科", country: "俄罗斯", population: "1256万", color: .orange),
            CityData(name: "孟买", country: "印度", population: "2042万", color: .brown),
            CityData(name: "上海", country: "中国", population: "2489万", color: .red),
            CityData(name: "圣保罗", country: "巴西", population: "1252万", color: .cyan),
            CityData(name: "洛杉矶", country: "美国", population: "1302万", color: .blue),
            CityData(name: "德里", country: "印度", population: "3255万", color: .brown),
            CityData(name: "首尔", country: "韩国", population: "954万", color: .magenta),
            CityData(name: "雅加达", country: "印尼", population: "1073万", color: .systemTeal),
            CityData(name: "马尼拉", country: "菲律宾", population: "1397万", color: .systemYellow),
            CityData(name: "开罗", country: "埃及", population: "2067万", color: .systemOrange)
        ]
        
        planetView.updateLabels(cities)
        
        // 更新状态
        statusLabel.text = "🌍 世界主要城市 (\(cities.count)个)"
    }
    
    private func showCityInfo(_ city: CityData) {
        let alert = UIAlertController(title: city.name, message: """
        国家: \(city.country)
        人口: \(city.population)
        
        点击标签查看详细信息
        长按可进行更多操作
        """, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        alert.addAction(UIAlertAction(title: "聚焦", style: .default) { [weak self] _ in
            if let index = self?.planetView.labels.firstIndex(where: { $0.name == city.name }) {
                self?.planetView.focusOnLabel(at: index)
            }
        })
        
        present(alert, animated: true)
    }
}

// MARK: - City Data Model

struct CityData: PlanetLabelRepresentable {
    let name: String
    let country: String
    let population: String
    let color: UIColor
    
    var planetTitle: String { return name }
    var planetColor: UIColor { return color }
    var planetIcon: UIImage? { return nil }
}
