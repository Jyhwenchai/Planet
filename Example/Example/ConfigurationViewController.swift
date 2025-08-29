//
//  ConfigurationViewController.swift
//  Example
//
//  Created by didong on 2025/8/28.
//  动态配置演示 - 使用纯 frame 布局
//

import UIKit
import Planet

class ConfigurationViewController: UIViewController {
    
    private var planetView: PlanetView<CompanyData>!
    private let controlsView = UIView()
    
    // 控件
    private let speedSlider = UISlider()
    private let speedLabel = UILabel()
    private let scaleSlider = UISlider()
    private let scaleLabel = UILabel()
    private let backgroundSwitch = UISwitch()
    private let autoRotationSwitch = UISwitch()
    private let resetButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupControls()
        setupPlanetView()
        loadCompanyData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 创建星球视图
        planetView = PlanetView<CompanyData>()
        view.addSubview(planetView)
        
        // 创建控制面板
        controlsView.backgroundColor = UIColor.systemGray6
        controlsView.layer.cornerRadius = 12
        view.addSubview(controlsView)
    }
    
    private func setupControls() {
        // 旋转速度标题
        let speedTitleLabel = UILabel()
        speedTitleLabel.text = "旋转速度"
        speedTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        // 旋转速度滑块
        speedSlider.minimumValue = 0
        speedSlider.maximumValue = 0.02
        speedSlider.value = 0.008
        speedSlider.addTarget(self, action: #selector(speedChanged), for: .valueChanged)
        
        // 旋转速度数值标签
        speedLabel.text = "0.008"
        speedLabel.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .medium)
        speedLabel.textAlignment = .right
        
        // 缩放比例标题
        let scaleTitleLabel = UILabel()
        scaleTitleLabel.text = "缩放比例"
        scaleTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        // 缩放滑块
        scaleSlider.minimumValue = 0.3
        scaleSlider.maximumValue = 2.0
        scaleSlider.value = 1.0
        scaleSlider.addTarget(self, action: #selector(scaleChanged), for: .valueChanged)
        
        // 缩放数值标签
        scaleLabel.text = "1.00"
        scaleLabel.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .medium)
        scaleLabel.textAlignment = .right
        
        // 背景开关标题
        let backgroundTitleLabel = UILabel()
        backgroundTitleLabel.text = "显示背景"
        backgroundTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        // 背景开关
        backgroundSwitch.isOn = true
        backgroundSwitch.addTarget(self, action: #selector(backgroundToggled), for: .valueChanged)
        
        // 自动旋转开关标题
        let autoRotationTitleLabel = UILabel()
        autoRotationTitleLabel.text = "自动旋转"
        autoRotationTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        // 自动旋转开关
        autoRotationSwitch.isOn = true
        autoRotationSwitch.addTarget(self, action: #selector(autoRotationToggled), for: .valueChanged)
        
        // 重置按钮
        resetButton.setTitle("重置设置", for: .normal)
        resetButton.backgroundColor = .systemBlue
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        resetButton.addTarget(self, action: #selector(resetSettings), for: .touchUpInside)
        
        // 添加所有控件到控制面板
        [speedTitleLabel, speedSlider, speedLabel, scaleTitleLabel, scaleSlider, scaleLabel,
         backgroundTitleLabel, backgroundSwitch, autoRotationTitleLabel, autoRotationSwitch, resetButton].forEach {
            controlsView.addSubview($0)
        }
    }
    
    private func updateLayout() {
        let safeArea = view.safeAreaInsets
        let margin: CGFloat = 20
        let spacing: CGFloat = 16
        let controlHeight: CGFloat = 44
        
        // 星球视图布局
        let planetSize = min(view.bounds.width - margin * 2, 350)
        planetView.frame = CGRect(
            x: (view.bounds.width - planetSize) / 2,
            y: safeArea.top + margin,
            width: planetSize,
            height: planetSize
        )
        
        // 控制面板布局
        let controlsHeight: CGFloat = 300
        controlsView.frame = CGRect(
            x: margin,
            y: planetView.frame.maxY + margin,
            width: view.bounds.width - margin * 2,
            height: controlsHeight
        )
        
        // 控制面板内部布局
        var currentY: CGFloat = margin
        let controlWidth = controlsView.bounds.width - margin * 2
        
        // 旋转速度控制
        if let speedTitleLabel = controlsView.subviews.first(where: { ($0 as? UILabel)?.text == "旋转速度" }) {
            speedTitleLabel.frame = CGRect(x: margin, y: currentY, width: controlWidth - 60, height: 20)
            speedLabel.frame = CGRect(x: controlsView.bounds.width - 80, y: currentY, width: 60, height: 20)
            currentY += 28
            speedSlider.frame = CGRect(x: margin, y: currentY, width: controlWidth, height: controlHeight)
            currentY += controlHeight + spacing
        }
        
        // 缩放比例控制
        if let scaleTitleLabel = controlsView.subviews.first(where: { ($0 as? UILabel)?.text == "缩放比例" }) {
            scaleTitleLabel.frame = CGRect(x: margin, y: currentY, width: controlWidth - 60, height: 20)
            scaleLabel.frame = CGRect(x: controlsView.bounds.width - 80, y: currentY, width: 60, height: 20)
            currentY += 28
            scaleSlider.frame = CGRect(x: margin, y: currentY, width: controlWidth, height: controlHeight)
            currentY += controlHeight + spacing
        }
        
        // 开关控制
        if let backgroundTitleLabel = controlsView.subviews.first(where: { ($0 as? UILabel)?.text == "显示背景" }) {
            backgroundTitleLabel.frame = CGRect(x: margin, y: currentY, width: controlWidth - 60, height: controlHeight)
            backgroundSwitch.frame = CGRect(x: controlsView.bounds.width - 71, y: currentY + 6, width: 51, height: 32)
            currentY += controlHeight + 8
        }
        
        if let autoRotationTitleLabel = controlsView.subviews.first(where: { ($0 as? UILabel)?.text == "自动旋转" }) {
            autoRotationTitleLabel.frame = CGRect(x: margin, y: currentY, width: controlWidth - 60, height: controlHeight)
            autoRotationSwitch.frame = CGRect(x: controlsView.bounds.width - 71, y: currentY + 6, width: 51, height: 32)
            currentY += controlHeight + spacing
        }
        
        // 重置按钮
        resetButton.frame = CGRect(x: margin, y: currentY, width: controlWidth, height: controlHeight)
    }
    
    @objc private func speedChanged() {
        let value = CGFloat(speedSlider.value)
        speedLabel.text = String(format: "%.3f", value)
        planetView.setAutoRotationSpeed(value)
    }
    
    @objc private func scaleChanged() {
        let value = CGFloat(scaleSlider.value)
        scaleLabel.text = String(format: "%.2f", value)
        planetView.setScale(value)
    }
    
    @objc private func backgroundToggled() {
        toggleBackground(backgroundSwitch.isOn)
    }
    
    @objc private func autoRotationToggled() {
        if autoRotationSwitch.isOn {
            planetView.resumeAnimations()
        } else {
            planetView.pauseAnimations()
        }
    }
    
    @objc private func resetSettings() {
        speedSlider.value = 0.008
        scaleSlider.value = 1.0
        backgroundSwitch.isOn = true
        autoRotationSwitch.isOn = true
        
        speedLabel.text = "0.008"
        scaleLabel.text = "1.00"
        
        planetView.setAutoRotationSpeed(0.008)
        planetView.setScale(1.0)
        toggleBackground(true)
        planetView.resumeAnimations()
    }
    
    private func setupPlanetView() {
        planetView.onLabelTap = { [weak self] company, index in
            self?.showCompanyInfo(company)
        }
    }
    
    private func loadCompanyData() {
        let companies = [
            CompanyData(name: "Apple", industry: "科技", country: "美国", color: .systemBlue),
            CompanyData(name: "Google", industry: "互联网", country: "美国", color: .systemRed),
            CompanyData(name: "Microsoft", industry: "软件", country: "美国", color: .systemGreen),
            CompanyData(name: "Amazon", industry: "电商", country: "美国", color: .systemOrange),
            CompanyData(name: "Tesla", industry: "汽车", country: "美国", color: .systemPurple),
            CompanyData(name: "阿里巴巴", industry: "电商", country: "中国", color: .systemYellow),
            CompanyData(name: "腾讯", industry: "互联网", country: "中国", color: .systemTeal),
            CompanyData(name: "三星", industry: "电子", country: "韩国", color: .systemIndigo),
            CompanyData(name: "丰田", industry: "汽车", country: "日本", color: .systemPink),
            CompanyData(name: "Meta", industry: "社交", country: "美国", color: .cyan)
        ]
        
        planetView.updateLabels(companies)
    }
    
    private func toggleBackground(_ show: Bool) {
        var config = planetView.configuration
        config.appearance.planetBackground.isVisible = show
        planetView.configuration = config
    }
    
    private func showCompanyInfo(_ company: CompanyData) {
        let alert = UIAlertController(title: company.name, message: """
        行业: \(company.industry)
        国家: \(company.country)
        
        尝试调整下方的控制参数
        观察星球视图的变化
        """, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Company Data Model

struct CompanyData: PlanetLabelRepresentable {
    let name: String
    let industry: String
    let country: String
    let color: UIColor
    
    var planetTitle: String { return name }
    var planetColor: UIColor { return color }
    var planetIcon: UIImage? { return nil }
}
