//
//  AnimationViewController.swift
//  Example
//
//  Created by didong on 2025/8/28.
//  动画效果演示 - 使用纯 frame 布局
//

import UIKit
import Planet

class AnimationViewController: UIViewController {
    
    private var planetView: PlanetView<GameData>!
    private let buttonsView = UIView()
    private let statusLabel = UILabel()
    
    // 动画按钮
    private let rotateButton = UIButton(type: .system)
    private let focusButton = UIButton(type: .system)
    private let scaleButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let randomDataButton = UIButton(type: .system)
    
    private var currentFocusIndex = 0
    private var isScaledUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtons()
        setupPlanetView()
        loadGameData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0) // 深色背景
        
        // 状态标签
        statusLabel.text = "🎮 游戏数据展示"
        statusLabel.textColor = .white
        statusLabel.font = UIFont.boldSystemFont(ofSize: 18)
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        
        // 创建星球视图
        planetView = PlanetView<GameData>(configuration: createAnimationConfiguration())
        view.addSubview(planetView)
        
        // 按钮面板
        buttonsView.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        buttonsView.layer.cornerRadius = 12
        buttonsView.layer.borderWidth = 1
        buttonsView.layer.borderColor = UIColor.systemBlue.cgColor
        view.addSubview(buttonsView)
    }
    
    private func createAnimationConfiguration() -> PlanetConfiguration {
        var config = PlanetConfiguration.default
        
        // 背景设置
        config.appearance.planetBackground.isVisible = true
        config.appearance.planetBackground.backgroundType = .gradient
        config.appearance.planetBackground.gradientColors = [
            UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 0.9),
            UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 0.7),
            UIColor(red: 0.05, green: 0.1, blue: 0.3, alpha: 0.5)
        ]
        
        // 标签样式 - 启用跑马灯效果
        config.appearance.labelStyle.textStyle.enableMarquee = true
        config.appearance.labelStyle.textStyle.color = .white
        config.appearance.labelStyle.textStyle.font = UIFont.boldSystemFont(ofSize: 12)
        config.appearance.labelStyle.textStyle.maxWidth = 100
        config.appearance.labelStyle.circleStyle.size = 10
        config.appearance.labelStyle.layoutType = .textAboveCircle
        
        // 跑马灯配置
        config.appearance.labelStyle.textStyle.marqueeConfig.scrollSpeed = 20
        config.appearance.labelStyle.textStyle.marqueeConfig.scrollDelay = 1.5
        config.appearance.labelStyle.textStyle.marqueeConfig.enableFadeEdge = true
        
        // 动画设置
        config.animation.autoRotation.isEnabled = true
        config.animation.autoRotation.initialSpeed = 0.005
        config.animation.gestureResponse.inertia.isEnabled = true
        
        return config
    }
    
    private func setupButtons() {
        // 旋转动画按钮
        rotateButton.setTitle("🔄 随机旋转", for: .normal)
        rotateButton.setTitleColor(.white, for: .normal)
        rotateButton.backgroundColor = .systemBlue
        rotateButton.layer.cornerRadius = 8
        rotateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        rotateButton.addTarget(self, action: #selector(randomRotate), for: .touchUpInside)
        
        // 聚焦动画按钮
        focusButton.setTitle("🎯 聚焦下一个", for: .normal)
        focusButton.setTitleColor(.white, for: .normal)
        focusButton.backgroundColor = .systemGreen
        focusButton.layer.cornerRadius = 8
        focusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        focusButton.addTarget(self, action: #selector(focusNext), for: .touchUpInside)
        
        // 缩放动画按钮
        scaleButton.setTitle("📏 切换缩放", for: .normal)
        scaleButton.setTitleColor(.white, for: .normal)
        scaleButton.backgroundColor = .systemPurple
        scaleButton.layer.cornerRadius = 8
        scaleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        scaleButton.addTarget(self, action: #selector(toggleScale), for: .touchUpInside)
        
        // 重置按钮
        resetButton.setTitle("🔄 重置视图", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = .systemOrange
        resetButton.layer.cornerRadius = 8
        resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        resetButton.addTarget(self, action: #selector(resetView), for: .touchUpInside)
        
        // 随机数据按钮
        randomDataButton.setTitle("🎲 随机数据", for: .normal)
        randomDataButton.setTitleColor(.white, for: .normal)
        randomDataButton.backgroundColor = .systemRed
        randomDataButton.layer.cornerRadius = 8
        randomDataButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        randomDataButton.addTarget(self, action: #selector(loadRandomData), for: .touchUpInside)
        
        // 添加所有按钮
        [rotateButton, focusButton, scaleButton, resetButton, randomDataButton].forEach {
            buttonsView.addSubview($0)
        }
    }
    
    private func updateLayout() {
        let safeArea = view.safeAreaInsets
        let margin: CGFloat = 20
        
        // 状态标签
        statusLabel.frame = CGRect(
            x: margin,
            y: safeArea.top + 10,
            width: view.bounds.width - margin * 2,
            height: 30
        )
        
        // 星球视图
        let planetSize = min(view.bounds.width - margin * 2, 320)
        planetView.frame = CGRect(
            x: (view.bounds.width - planetSize) / 2,
            y: statusLabel.frame.maxY + margin,
            width: planetSize,
            height: planetSize
        )
        
        // 按钮面板
        let buttonsHeight: CGFloat = 200
        buttonsView.frame = CGRect(
            x: margin,
            y: planetView.frame.maxY + margin,
            width: view.bounds.width - margin * 2,
            height: buttonsHeight
        )
        
        // 按钮布局
        let buttonSpacing: CGFloat = 10
        let buttonHeight: CGFloat = 35
        let buttonsPerRow = 2
        let buttonWidth = (buttonsView.bounds.width - margin * 2 - buttonSpacing) / CGFloat(buttonsPerRow)
        
        let buttons = [rotateButton, focusButton, scaleButton, resetButton, randomDataButton]
        for (index, button) in buttons.enumerated() {
            let row = index / buttonsPerRow
            let col = index % buttonsPerRow
            
            let x = margin + CGFloat(col) * (buttonWidth + buttonSpacing)
            let y = margin + CGFloat(row) * (buttonHeight + buttonSpacing)
            
            // 最后一个按钮占满整行
            if index == buttons.count - 1 && buttons.count % buttonsPerRow != 0 {
                button.frame = CGRect(x: margin, y: y, width: buttonsView.bounds.width - margin * 2, height: buttonHeight)
            } else {
                button.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
            }
        }
    }
    
    private func setupPlanetView() {
        // 标签点击事件
        planetView.onLabelTap = { [weak self] game, index in
            self?.showGameInfo(game, at: index)
        }
        
        // 标签长按事件
        planetView.onLabelLongPress = { [weak self] game, index in
            self?.focusOnGame(at: index)
        }
        
        // 旋转状态改变事件
        planetView.onRotationChanged = { [weak self] rotation in
            self?.updateStatus()
        }
    }
    
    private func loadGameData() {
        let games = [
            GameData(name: "王者荣耀", genre: "MOBA", platform: "手机", color: .systemBlue),
            GameData(name: "原神", genre: "RPG", platform: "多平台", color: .systemPurple),
            GameData(name: "和平精英", genre: "射击", platform: "手机", color: .systemGreen),
            GameData(name: "英雄联盟", genre: "MOBA", platform: "PC", color: .systemIndigo),
            GameData(name: "我的世界", genre: "沙盒", platform: "多平台", color: .systemBrown),
            GameData(name: "Among Us", genre: "社交推理", platform: "多平台", color: .systemRed),
            GameData(name: "塞尔达传说：旷野之息", genre: "冒险", platform: "Switch", color: .systemTeal),
            GameData(name: "使命召唤：手游", genre: "射击", platform: "手机", color: .systemOrange),
            GameData(name: "糖豆人终极淘汰赛", genre: "竞技", platform: "多平台", color: .systemPink),
            GameData(name: "赛博朋克2077", genre: "RPG", platform: "PC/主机", color: .systemYellow)
        ]
        
        planetView.updateLabels(games)
        updateStatus()
    }
    
    private func updateStatus() {
        let visibleCount = planetView.visibleLabelCount()
        statusLabel.text = "🎮 游戏数据展示 (可见: \(visibleCount)/\(planetView.labels.count))"
    }
    
    @objc private func randomRotate() {
        // 生成随机旋转
        let randomX = Float.random(in: -1...1)
        let randomY = Float.random(in: -1...1)
        let randomZ = Float.random(in: -1...1)
        let randomAngle = Float.random(in: 0...2 * Float.pi)
        
        let axis = Vector3(x: CGFloat(randomX), y: CGFloat(randomY), z: CGFloat(randomZ)).normalized()
        let targetRotation = Quaternion(axis: axis, angle: CGFloat(randomAngle))
        
        planetView.animateRotation(to: targetRotation, duration: 1.5) { [weak self] in
            self?.showMessage("旋转完成！")
        }
    }
    
    @objc private func focusNext() {
        guard !planetView.labels.isEmpty else { return }
        
        currentFocusIndex = (currentFocusIndex + 1) % planetView.labels.count
        let game = planetView.labels[currentFocusIndex]
        
        planetView.focusOnLabel(at: currentFocusIndex, duration: 1.2) { [weak self] in
            self?.showMessage("聚焦到: \(game.name)")
        }
    }
    
    @objc private func toggleScale() {
        let targetScale: CGFloat = isScaledUp ? 1.0 : 1.5
        isScaledUp = !isScaledUp
        
        planetView.animateScale(to: targetScale, duration: 0.8) { [weak self] in
            let status = self?.isScaledUp == true ? "放大" : "还原"
            self?.showMessage("缩放\(status)完成！")
        }
    }
    
    @objc private func resetView() {
        planetView.resetRotation()
        planetView.setScale(1.0)
        isScaledUp = false
        currentFocusIndex = 0
        
        showMessage("视图已重置！")
    }
    
    @objc private func loadRandomData() {
        let allGames = [
            GameData(name: "王者荣耀", genre: "MOBA", platform: "手机", color: .systemBlue),
            GameData(name: "原神", genre: "RPG", platform: "多平台", color: .systemPurple),
            GameData(name: "和平精英", genre: "射击", platform: "手机", color: .systemGreen),
            GameData(name: "英雄联盟", genre: "MOBA", platform: "PC", color: .systemIndigo),
            GameData(name: "我的世界", genre: "沙盒", platform: "多平台", color: .systemBrown),
            GameData(name: "Among Us", genre: "社交推理", platform: "多平台", color: .systemRed),
            GameData(name: "塞尔达传说", genre: "冒险", platform: "Switch", color: .systemTeal),
            GameData(name: "使命召唤", genre: "射击", platform: "手机", color: .systemOrange),
            GameData(name: "糖豆人", genre: "竞技", platform: "多平台", color: .systemPink),
            GameData(name: "赛博朋克2077", genre: "RPG", platform: "PC", color: .systemYellow),
            GameData(name: "动物森友会", genre: "模拟", platform: "Switch", color: .cyan),
            GameData(name: "堡垒之夜", genre: "射击", platform: "多平台", color: .systemTeal),
            GameData(name: "超级马里奥", genre: "平台", platform: "Switch", color: .systemRed),
            GameData(name: "FIFA 2024", genre: "体育", platform: "多平台", color: .systemBlue),
            GameData(name: "街霸6", genre: "格斗", platform: "多平台", color: .systemOrange)
        ]
        
        // 随机选择游戏数量和游戏
        let gameCount = Int.random(in: 6...12)
        let selectedGames = Array(allGames.shuffled().prefix(gameCount))
        
        planetView.updateLabels(selectedGames)
        updateStatus()
        showMessage("加载了 \(gameCount) 个随机游戏！")
    }
    
    private func focusOnGame(at index: Int) {
        planetView.focusOnLabel(at: index, duration: 1.0) { [weak self] in
            let game = self?.planetView.labels[index]
            self?.showMessage("长按聚焦到: \(game?.name ?? "")")
        }
    }
    
    private func showGameInfo(_ game: GameData, at index: Int) {
        let alert = UIAlertController(title: game.name, message: """
        类型: \(game.genre)
        平台: \(game.platform)
        位置: 第 \(index + 1) 个
        
        💡 提示：
        • 长按标签可以聚焦
        • 拖拽可以旋转星球
        • 捏合手势可以缩放
        """, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "聚焦此游戏", style: .default) { [weak self] _ in
            self?.focusOnGame(at: index)
        })
        alert.addAction(UIAlertAction(title: "确定", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
        
        // 1秒后自动关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
}

// MARK: - Game Data Model

struct GameData: PlanetLabelRepresentable {
    let name: String
    let genre: String
    let platform: String
    let color: UIColor
    
    var planetTitle: String { return name }
    var planetColor: UIColor { return color }
    var planetIcon: UIImage? { return nil }
}
