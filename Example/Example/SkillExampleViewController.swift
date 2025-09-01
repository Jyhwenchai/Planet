//
//  SkillExampleViewController.swift
//  Example
//
//  Created by didong on 2025/8/28.
//  技能展示的 Planet 视图示例
//

import UIKit
import Planet

class SkillExampleViewController: UIViewController {
    
    private var planetView: PlanetView<SkillData>!
    private let skillTitles = [
        "UI设计", "网站开发", "商务外语", "全栈财务", "媒体代运营",
        "人力资源管理", "营销策划", "项目申报", "知识产权交易管理", "软件实施",
        "法务咨询", "市场推广", "企业培训", "相册", "策划写作",
        "我的星球", "数据分析与处理", "电商运营", "产品设计", "市场调研",
        "品牌策划与推广", "内容创作", "社群运营", "项目管理", "财务分析",
        "质量控制管理", "客户服务", "供应链管理与优化", "人才招聘", "培训开发",
        "行政管理", "公共关系管理", "投资理财", "风险管理与控制", "技术支持与维护"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlanetView()
        loadSkillData()
    }
    
//  override func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//         // 设置初始旋转状态为东南方向 - 立即生效，不需要等待自旋
//      self.planetView.pauseAnimations()
//      let southeastRotation = Quaternion(
//        pitch: PlanetMath.degreesToRadians(-30), // 向下倾斜30度（更明显的透视效果）
//        yaw: PlanetMath.degreesToRadians(50),   // 向右旋转50度（更明显的东南方向）
//        roll: PlanetMath.degreesToRadians(5)    // 轻微滚动增加视觉效果
//      )
//      self.planetView.setRotation(southeastRotation)
//        // 3. 重新启动自动旋转（从当前角度开始朝东南方向旋转）
//      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//        self.planetView.resumeAnimations()
//      }
//    }
//  }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0) // 深蓝色背景
        
        // 创建星球视图
        planetView = PlanetView<SkillData>()
        planetView.translatesAutoresizingMaskIntoConstraints = false
        // 增强深度透视效果
        planetView.configuration.appearance.depthEffects.depthScaleRange = 0.3...1.0
        planetView.configuration.appearance.depthEffects.depthAlphaRange = 0.2...1.0
        planetView.configuration.appearance.depthEffects.enableDepthColorAdjustment = true
        planetView.configuration.appearance.depthEffects.depthColorIntensity = 0.4
      planetView.configuration.animation.autoRotation.initialSpeed = 0.001
        
        // 设置自动旋转的轴为东南方向（更明显的东南效果）
        planetView.configuration.animation.autoRotation.initialAxis = Vector3(
            x: 0.5,  // 东方分量
            y: 0.5,  // 减少Y分量以增强水平旋转效果
            z: 0.5   // 南方分量
        ).normalized() // 归一化确保是单位向量
        view.addSubview(planetView)
        
        NSLayoutConstraint.activate([
            planetView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            planetView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            planetView.widthAnchor.constraint(equalToConstant: 350),
            planetView.heightAnchor.constraint(equalToConstant: 350)
        ])
        
        // 添加说明标签
        let instructionLabel = UILabel()
        instructionLabel.text = "点击技能标签查看详情"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupPlanetView() {
        // 设置点击事件
        planetView.onLabelTap = { [weak self] data, index in
            self?.showSkillDetail(skill: data)
        }
        
        // 设置初始旋转状态为东南方向
//        let southeastRotation = Quaternion(
//            pitch: PlanetMath.degreesToRadians(-30), // 向下倾斜30度
//            yaw: PlanetMath.degreesToRadians(50),   // 向右旋转50度（东南方向）
//            roll: PlanetMath.degreesToRadians(5)    // 轻微滚动增加视觉效果
//        )
//        planetView.setRotation(southeastRotation)
        
        // 调试信息
        print("🔧 设置初始旋转完成")
        print("🔧 autoRotation.isEnabled: \(planetView.configuration.animation.autoRotation.isEnabled)")
        print("🔧 currentRotation: \(planetView.currentRotation)")
    }
    
    private func loadSkillData() {
        // 启用透视投影以增强3D效果
        planetView.configuration.layout.projection.type = .perspective
        planetView.configuration.layout.projection.fieldOfView = 45  // 较小的视场角增强透视效果
        
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple,
            .systemTeal, .systemIndigo, .systemPink, .systemYellow, .red,
            .blue, .systemBrown, .systemGray, .systemRed, .systemBlue,
            .systemGreen, .systemOrange, .systemPurple, .systemTeal, .systemIndigo,
            .systemPink, .systemYellow, .green, .orange, .systemBrown,
            .systemGray, .systemRed, .systemBlue, .systemGreen, .systemOrange,
            .systemPurple, .systemTeal, .systemIndigo, .systemPink, .systemYellow
        ]
        
        let categories = [
            "设计类", "开发类", "语言类", "财务类", "运营类",
            "管理类", "策划类", "法务类", "知识产权", "技术类",
            "法务类", "营销类", "培训类", "工具类", "写作类",
            "个人", "数据类", "电商类", "设计类", "调研类",
            "品牌类", "内容类", "社群类", "项目类", "财务类",
            "质量类", "服务类", "供应链", "招聘类", "培训类",
            "行政类", "公关类", "理财类", "风险类", "技术类"
        ]
        
        let skillData = skillTitles.enumerated().map { index, title in
            SkillData(
                title: title,
                category: categories[index],
                color: colors[index % colors.count],
                index: index
            )
        }
        
        planetView.updateLabels(skillData)
    }
    
    private func showSkillDetail(skill: SkillData) {
        let alert = UIAlertController(
            title: "技能详情",
            message: "技能: \(skill.title)\n类别: \(skill.category)\n编号: \(skill.index + 1)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "关闭", style: .default))
        
        // 如果是特殊技能，添加更多操作
        if skill.title == "我的星球" {
            alert.addAction(UIAlertAction(title: "了解更多", style: .default) { _ in
                self.showPlanetInfo()
            })
        }
        
        present(alert, animated: true)
    }
    
    private func showSkillDescription(skill: SkillData) {
        let descriptions = [
            "UI设计": "用户界面设计，专注于产品的视觉呈现和用户体验",
            "网站开发": "网站建设与开发，包括前端和后端技术",
            "商务外语": "商务场景中的外语沟通与翻译服务",
            "全栈财务": "全面的财务管理和分析服务",
            "媒体代运营": "社交媒体平台的运营和管理服务",
            "我的星球": "个人技能展示平台，就像这个星球一样！",
            // 可以继续添加更多描述
        ]
        
        let description = descriptions[skill.title] ?? "这是一个专业的\(skill.category)技能"
        
        let alert = UIAlertController(
            title: skill.title,
            message: description,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "关闭", style: .default))
        present(alert, animated: true)
    }
    
    private func showPlanetInfo() {
        let alert = UIAlertController(
            title: "关于我的星球",
            message: "这是一个展示个人技能的3D星球视图，每个标签代表一项技能。你可以点击标签查看详情。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "太酷了！", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Skill Data Model

struct SkillData: PlanetLabelRepresentable {
    let title: String
    let category: String
    let color: UIColor
    let index: Int
    var icon: UIImage? = nil
    
    var planetTitle: String { return title }
    var planetColor: UIColor { return color }
    var planetIcon: UIImage? { return icon }
}
