//
//  PlanetInteraction.swift
//  Planet
//
//  Created by didong on 2025/8/28.
//  星球交互模块 - 手势识别、动画控制、自动旋转等
//

import UIKit

// MARK: - 手势控制

extension PlanetView {
    
    /// 设置手势识别器
    internal func setupGestures() {
        // 移除所有现有手势
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
        
        guard configuration.interaction.isEnabled else { return }
        
        let supportedGestures = configuration.interaction.supportedGestures
        
        // 拖拽旋转手势
        if supportedGestures.contains(.pan) {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler))
            addGestureRecognizer(panGesture)
        }
        
        // 点击手势
        if supportedGestures.contains(.tap) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
            addGestureRecognizer(tapGesture)
        }
        
        // 长按手势
        if supportedGestures.contains(.longPress) {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureHandler))
            longPressGesture.minimumPressDuration = 0.5
            addGestureRecognizer(longPressGesture)
        }
        
        // 双击手势
        if supportedGestures.contains(.doubleTap) {
            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureHandler))
            doubleTapGesture.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTapGesture)
            
            // 让单击手势等待双击失败
            if let tapGesture = gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer && ($0 as! UITapGestureRecognizer).numberOfTapsRequired == 1 }) {
                tapGesture.require(toFail: doubleTapGesture)
            }
        }
        
        // 捏合缩放手势
        if supportedGestures.contains(.pinch) {
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureHandler))
            addGestureRecognizer(pinchGesture)
        }
    }
    
    // MARK: - 手势处理方法
    
    /// 处理拖拽手势
    internal func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let gestureConfig = configuration.animation.gestureResponse
        
        switch gesture.state {
        case .began:
            stopAutoRotation()
            stopInertiaScrolling()
            isUserInteracting = true
            
        case .changed:
            let translation = gesture.translation(in: self)
            
            // 轨迹球旋转：根据2D手势创建3D旋转轴和角度
            let rotationAxis = Vector3(x: translation.y, y: translation.x, z: 0).normalized()
            let rotationAngle = sqrt(translation.x * translation.x + translation.y * translation.y) * gestureConfig.rotationSensitivity
            
            if rotationAngle > 0.001 {
                let deltaQuaternion = Quaternion(axis: rotationAxis, angle: rotationAngle)
                currentRotation = deltaQuaternion.multiply(currentRotation).normalized()
                
                // 记住手势方向用于自动旋转
                if configuration.animation.autoRotation.rememberGestureDirection {
                    updateAutoRotationDirection(from: rotationAxis, angle: rotationAngle)
                }
            }
            
            // 重置translation获得增量效果
            gesture.setTranslation(.zero, in: self)
            
            // 更新显示
            updateAllLabelPositions()
            
        case .ended, .cancelled:
            isUserInteracting = false
            
            // 处理惯性滚动
            let velocity = gesture.velocity(in: self)
            let velocityMagnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            
            if gestureConfig.inertia.isEnabled && velocityMagnitude > gestureConfig.inertia.minimumVelocity {
                startInertiaScrolling(velocity: velocity)
            } else {
                startAutoRotationIfNeeded()
            }
            
        default:
            break
        }
    }
    
    /// 处理点击手势
    internal func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        let location = gesture.location(in: self)
        let hitConfig = configuration.interaction.hitTesting
        
        if let hitLabelData = labelManager.labelData(at: location, config: hitConfig) {
            // 播放点击动画
            if configuration.animation.clickAnimation.isEnabled {
                hitLabelData.playClickAnimation(with: configuration.animation.clickAnimation)
            }
            
            // 触发回调
            onLabelTap?(hitLabelData.originalData, hitLabelData.index)
            
            print("🎯 标签被点击: \(hitLabelData.title)")
        }
    }
    
    /// 处理长按手势
    internal func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: self)
        let hitConfig = configuration.interaction.hitTesting
        
        if let hitLabelData = labelManager.labelData(at: location, config: hitConfig) {
            // 触发长按回调
            onLabelLongPress?(hitLabelData.originalData, hitLabelData.index)
            
            print("👆 标签被长按: \(hitLabelData.title)")
        }
    }
    
    /// 处理双击手势
    internal func handleDoubleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        // 双击重置视图
        resetRotation()
        setScale(configuration.animation.gestureResponse.scaling.defaultScale)
        
        print("🔄 双击重置星球")
    }
    
    /// 处理捏合缩放手势
    internal func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard configuration.animation.gestureResponse.scaling.isEnabled else { return }
        
        switch gesture.state {
        case .began:
            stopAutoRotation()
            isUserInteracting = true
            
        case .changed:
            let scaleFactor = gesture.scale * configuration.animation.gestureResponse.scaling.pinchSensitivity
            let newScale = currentScale * scaleFactor
            setScale(newScale)
            gesture.scale = 1.0  // 重置缩放因子
            
        case .ended, .cancelled:
            isUserInteracting = false
            startAutoRotationIfNeeded()
            
        default:
            break
        }
    }
}

// MARK: - 自动旋转控制

extension PlanetView {
    
    /// 开始自动旋转（如果配置允许）
    internal func startAutoRotationIfNeeded() {
        guard configuration.animation.autoRotation.isEnabled && !isUserInteracting else { return }
        startAutoRotation()
    }
    
    /// 开始自动旋转
    private func startAutoRotation() {
        guard autoRotationTimer == nil else { return }
        
        let frameRate = configuration.animation.autoRotation.frameRate
        
        autoRotationTimer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 🔑 Swift 6 修复：使用 MainActor 确保在主线程执行
            Task { @MainActor in
                guard !self.isUserInteracting,
                      !self.isInertiaScrolling else { return }
                
                // 应用自动旋转
                let autoRotationQuaternion = Quaternion(axis: self.autoRotationAxis, angle: self.autoRotationSpeed)
                self.currentRotation = autoRotationQuaternion.multiply(self.currentRotation).normalized()
                self.updateAllLabelPositions()
            }
        }
    }
    
    /// 停止自动旋转
    internal func stopAutoRotation() {
        autoRotationTimer?.invalidate()
        autoRotationTimer = nil
    }
    
    /// 更新自动旋转方向
    /// - Parameters:
    ///   - gestureAxis: 手势旋转轴
    ///   - angle: 旋转角度
    private func updateAutoRotationDirection(from gestureAxis: Vector3, angle: CGFloat) {
        autoRotationAxis = gestureAxis
        
        let config = configuration.animation.autoRotation
        
        // 根据手势强度调整自动旋转速度
        let speedFactor = PlanetMath.clamp(
            angle / configuration.animation.gestureResponse.rotationSensitivity / 50.0,
            min: 0.3,
            max: 2.0
        )
        
        autoRotationSpeed = PlanetMath.clamp(
            config.initialSpeed * speedFactor,
            min: config.speedRange.lowerBound,
            max: config.speedRange.upperBound
        )
    }
}

// MARK: - 惯性滚动

extension PlanetView {
    
    /// 开始惯性滚动
    /// - Parameter velocity: 手势速度
    private func startInertiaScrolling(velocity: CGPoint) {
        // Remove unused variable
        // let inertiaConfig = configuration.animation.gestureResponse.inertia
        
        isInertiaScrolling = true
        inertiaVelocity = CGPoint(
            x: velocity.x * 0.0001,
            y: velocity.y * 0.0001
        )
        
        animateInertiaScrolling()
    }
    
    /// 停止惯性滚动
    private func stopInertiaScrolling() {
        isInertiaScrolling = false
    }
    
    /// 惯性动画循环
    private func animateInertiaScrolling() {
        guard isInertiaScrolling else { return }
        
        let inertiaConfig = configuration.animation.gestureResponse.inertia
        _ = configuration.animation.gestureResponse.rotationSensitivity
        
        // 应用惯性旋转
        let rotationAxis = Vector3(x: inertiaVelocity.y, y: inertiaVelocity.x, z: 0).normalized()
        let rotationAngle = sqrt(inertiaVelocity.x * inertiaVelocity.x + inertiaVelocity.y * inertiaVelocity.y)
        
        if rotationAngle > 0.001 {
            let inertiaQuaternion = Quaternion(axis: rotationAxis, angle: rotationAngle)
            currentRotation = inertiaQuaternion.multiply(currentRotation).normalized()
            
            // 在惯性滚动过程中也更新自动旋转方向
            if configuration.animation.autoRotation.rememberGestureDirection {
                updateAutoRotationDirection(from: rotationAxis, angle: rotationAngle)
            }
        }
        
        // 速度衰减
        inertiaVelocity.x *= inertiaConfig.decayRate
        inertiaVelocity.y *= inertiaConfig.decayRate
        
        // 更新显示
        updateAllLabelPositions()
        
        // 检查是否停止
        let velocityMagnitude = sqrt(inertiaVelocity.x * inertiaVelocity.x + inertiaVelocity.y * inertiaVelocity.y)
        if velocityMagnitude < inertiaConfig.stopThreshold {
            stopInertiaScrolling()
            startAutoRotationIfNeeded()
        } else {
            // 继续动画
            DispatchQueue.main.asyncAfter(deadline: .now() + inertiaConfig.frameRate) { [weak self] in
                self?.animateInertiaScrolling()
            }
        }
    }
}

// MARK: - 动画控制

public extension PlanetView {
    
    /// 动画到指定旋转
    /// - Parameters:
    ///   - targetRotation: 目标旋转四元数
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func animateRotation(
        to targetRotation: Quaternion,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        stopAutoRotation()
        
        let startRotation = currentRotation
        let startTime = CACurrentMediaTime()
        
        let animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            let progress = min(1.0, elapsed / duration)
            
            Task { @MainActor in
                // 使用球面线性插值
                let interpolatedRotation = startRotation.slerp(to: targetRotation, t: CGFloat(progress))
                self.currentRotation = interpolatedRotation
                self.updateAllLabelPositions()
            }
            
            if progress >= 1.0 {
                timer.invalidate()
                Task { @MainActor in
                    self.startAutoRotationIfNeeded()
                    completion?()
                }
//                DispatchQueue.main.async {
//                }
            }
        }
        
        // 保持对定时器的引用，避免被释放
//        Timer.scheduledTimer(withTimeInterval: duration + 0.1, repeats: false) { _ in
//            animationTimer.invalidate()
//        }
    }
    
    /// 动画到指定缩放
    /// - Parameters:
    ///   - targetScale: 目标缩放比例
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func animateScale(
        to targetScale: CGFloat,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        let startScale = currentScale
        let startTime = CACurrentMediaTime()
        
        let animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            let progress = min(1.0, elapsed / duration)
            
            Task { @MainActor in
                // 线性插值缩放
                let interpolatedScale = PlanetMath.lerp(startScale, targetScale, t: CGFloat(progress))
                self.setScale(interpolatedScale)
            }
            
            if progress >= 1.0 {
                timer.invalidate()
            }
        }
        
        // 保持对定时器的引用
//        Timer.scheduledTimer(withTimeInterval: duration + 0.1, repeats: false) { _ in
//            animationTimer.invalidate()
//        }
    }
    
    /// 平滑旋转到显示指定标签
    /// - Parameters:
    ///   - index: 标签索引
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    func focusOnLabel(
        at index: Int,
        duration: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        guard let labelData = labelManager.labelData(at: index) else {
            completion?()
            return
        }
        
        // 计算需要的旋转，让指定标签转到正前方
        let targetPosition = Vector3(x: 0, y: 0, z: 1)  // 正前方位置
        let currentPosition = labelData.originalPosition
        
        // 计算旋转轴（叉积）
        let rotationAxis = currentPosition.cross(targetPosition).normalized()
        
        // 计算旋转角度
        let rotationAngle = currentPosition.angleTo(targetPosition)
        
        // 创建目标四元数
        let focusRotation = Quaternion(axis: rotationAxis, angle: rotationAngle)
        let targetRotation = focusRotation.multiply(currentRotation)
        
        animateRotation(to: targetRotation, duration: duration, completion: completion)
    }
}

// MARK: - 公共控制方法

public extension PlanetView {
    
    /// 暂停所有动画
    func pauseAnimations() {
        stopAutoRotation()
        stopInertiaScrolling()
    }
    
    /// 恢复动画
    func resumeAnimations() {
        if !isUserInteracting {
            startAutoRotationIfNeeded()
        }
    }
    
    /// 设置自动旋转速度
    /// - Parameter speed: 旋转速度（弧度/秒）
    func setAutoRotationSpeed(_ speed: CGFloat) {
        let config = configuration.animation.autoRotation
        autoRotationSpeed = PlanetMath.clamp(
            speed,
            min: config.speedRange.lowerBound,
            max: config.speedRange.upperBound
        )
    }
    
    /// 设置自动旋转轴
    /// - Parameter axis: 旋转轴
    func setAutoRotationAxis(_ axis: Vector3) {
        autoRotationAxis = axis.normalized()
    }
    
    /// 获取当前是否在用户交互中
    /// - Returns: 是否在交互中
    func isCurrentlyInteracting() -> Bool {
        return isUserInteracting || isInertiaScrolling
    }
}
