//
//  BasicExampleViewController.swift
//  Example
//
//  Created by didong on 2025/8/28.
//  基础的 Planet 视图示例
//

import UIKit
import Planet

class BasicExampleViewController: UIViewController {
    
    private var planetView: PlanetView<SampleData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlanetView()
        loadSampleData()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // 创建星球视图
        planetView = PlanetView<SampleData>()
        planetView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(planetView)
        
        NSLayoutConstraint.activate([
            planetView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            planetView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            planetView.widthAnchor.constraint(equalToConstant: 350),
            planetView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }
    
    private func setupPlanetView() {
        // 设置点击事件
        planetView.onLabelTap = { [weak self] data, index in
            self?.showAlert(title: "点击了标签", message: "标签: \(data.title)\n索引: \(index)")
        }
    }
    
    private func loadSampleData() {
        let sampleData = [
            SampleData(title: "北京", subtitle: "中国首都", color: .red),
            SampleData(title: "上海", subtitle: "经济中心", color: .blue),
            SampleData(title: "广州", subtitle: "南方门户", color: .green),
            SampleData(title: "深圳", subtitle: "科技之城", color: .orange),
            SampleData(title: "杭州", subtitle: "电商之都", color: .purple),
            SampleData(title: "南京", subtitle: "六朝古都", color: .brown),
            SampleData(title: "成都", subtitle: "天府之国", color: .cyan),
            SampleData(title: "西安", subtitle: "十三朝古都", color: .magenta),
            SampleData(title: "重庆", subtitle: "山城雾都", color: .yellow),
            SampleData(title: "武汉", subtitle: "九省通衢", color: .systemIndigo)
        ]
        
        planetView.updateLabels(sampleData)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Sample Data Model

struct SampleData: PlanetLabelRepresentable {
    let title: String
    let subtitle: String
    let color: UIColor
    var icon: UIImage? = nil
    
    var planetTitle: String { return title }
    var planetColor: UIColor { return color }
    var planetIcon: UIImage? { return icon }
}
