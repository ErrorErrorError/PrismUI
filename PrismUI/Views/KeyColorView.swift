//
//  KeyView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyColorView: ColorView {

    // MARK: Public

    var prismKey: PrismKey! {
        didSet {
            updateAnimation()
        }
    }

    override var selected: Bool {
        set {
            CATransaction.lock()
            CATransaction.setAnimationDuration(0.15)
            backgroundLayer.borderWidth = newValue ? borderWidth : 0
            CATransaction.unlock()
            selected ? delegate?.didSelect(self) : delegate?.didDeselect(self)
            NotificationCenter.default.post(name: .keySelectionChanged, object: nil)
        }
        get {
            return backgroundLayer.borderWidth != 0
        }
    }

    override var color: NSColor {
        set {
            selectionLayer.backgroundColor = newValue.cgColor
            backgroundLayer.borderColor = newValue.cgColor
            dotLayer.backgroundColor = newValue.cgColor
        }

        get {
            return NSColor(cgColor: dotLayer.backgroundColor ?? CGColor.clear) ?? NSColor.clear
        }
    }

    private let textView = NSTextField(labelWithString: "")

    // MARK: Private

    // Layers

    private let selectionLayer: CALayer = {
        let layer = CALayer()
        layer.isOpaque = true
        layer.name = "selectionLayer"
        layer.actions = ["backgroundColor": NSNull()]
        return layer
    }()

    private let dotLayer = CALayer()

    private let borderWidth: CGFloat = 2
    private let backgroundOpacity: Float = 0.40
    private var text: NSString = NSString()
    private var transitionIndex = 0
    private var hasSetInitialWaveEffect = false

    private let baseDarkBackground = NSColor(calibratedRed: 0x1a/0xff,
                                             green: 0x1a/0xff,
                                             blue: 0x1a/0xff,
                                             alpha: 1.0)

    private let baseLightBackground = NSColor(calibratedRed: 0xf8/0xff,
                                              green: 0xf8/0xff,
                                              blue: 0xf8/0xff,
                                              alpha: 1.0)

    convenience init(text: String, key: PrismKey) {
        self.init()
        self.prismKey = key
        self.text = text as NSString
        color = prismKey.main.nsColor

        backgroundLayer.backgroundColor = baseDarkBackground.cgColor
        backgroundLayer.borderColor = color.cgColor
        backgroundLayer.borderWidth = 0
        backgroundLayer.name = "backgroundLayer"
        backgroundLayer.actions = ["backgroundColor": NSNull(),
                                   "borderColor": NSNull()]

        // Selection layer

        selectionLayer.backgroundColor = color.cgColor
        selectionLayer.cornerRadius = cornerRadius
        selectionLayer.opacity = backgroundOpacity
        layer?.addSublayer(selectionLayer)

        // Dot layer

        dotLayer.backgroundColor = color.cgColor
        dotLayer.name = "dotLayer"
        dotLayer.actions = ["backgroundColor": NSNull()]

        layer?.addSublayer(dotLayer)

        addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.stringValue = text
        textView.font = NSFont.boldSystemFont(ofSize: 14)
        textView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        let rect = NSRect(origin: CGPoint.zero, size: newSize)
        selectionLayer.frame = rect
        let newHeight = min(rect.height, rect.width) * 0.18
        let margin: CGFloat = 4
        dotLayer.frame = NSRect(origin: CGPoint(x: margin, y: rect.height - newHeight - margin),
                                size: CGSize(width: newHeight, height: newHeight))
        dotLayer.cornerRadius = dotLayer.frame.width/2
    }
}

// Update Animation

extension KeyColorView: CAAnimationDelegate {

    func updateAnimation() {
        layer?.removeAllAnimations()
        color = prismKey.main.nsColor
        if let effect = prismKey.effect {
            transitionIndex = 0
            hasSetInitialWaveEffect = false
            if effect.waveActive {
                animateWave()
            } else {
                animate()
            }
        }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let effect = prismKey.effect else {
            return
        }

        if flag {
            if effect.waveActive {
                self.animateWave()
            } else {
                self.animate()
            }
        }
    }

    private func animate() {
        guard let effect = prismKey.effect else {
            return
        }

        let transitions = effect.transitions
        let previousTransition = transitions[transitionIndex]
        transitionIndex + 1 < transitions.count ? (transitionIndex += 1) : (transitionIndex = 0)
        let nextTransition = transitions[transitionIndex]

        createAnimationBackground(fromColor: previousTransition.color.cgColor,
                                  toColor: nextTransition.color.cgColor,
                                  duration: CFTimeInterval(CGFloat(previousTransition.duration) / 100))
    }

    private func animateWave() {
        guard let originViewFrame = superview?.subviews.filter({ $0 is OriginEffectView }).first?.frame else { return }

        guard let effect = prismKey.effect else {
            return
        }

        let originPoint = effect.origin
        let originXFloat = CGFloat(originPoint.xPoint) / CGFloat(0x105c)
        let originYFloat = 1 - CGFloat(originPoint.yPoint) / CGFloat(0x040d)

        if effect.direction != .xyAxis {
            animateLinearWave(effect: effect,
                              originViewFrame: originViewFrame,
                              originX: originXFloat,
                              originY: originYFloat)
        } else {
            animateRadialWave(effect: effect,
                              originViewFrame: originViewFrame,
                              originX: originXFloat,
                              originY: originYFloat)
        }
    }

    private func animateRadialWave(effect: PrismEffect, originViewFrame: NSRect, originX: CGFloat, originY: CGFloat) {
        // TODO: Work on the radius animation

        let beforeColor, afterColor: CGColor
        let durationAnimation: CFTimeInterval
        var totalDur: CGFloat = 0

        let colorAndLocation = effect.transitions.compactMap { transition -> (PrismTransition, CGFloat) in
            let val = (transition, totalDur/CGFloat(effect.transitionDuration))
            totalDur += CGFloat(transition.duration)
            return val
        }

        if !hasSetInitialWaveEffect {
            let maxRadius = originViewFrame.height

            let keyPointX = frame.origin.x - originViewFrame.origin.x
            let keyPointY = frame.origin.y - originViewFrame.origin.y

            let viewPrismPointX = originX * originViewFrame.width
            let viewPrismPointY = originY * originViewFrame.height

            let distanceX = abs(viewPrismPointX - keyPointX)
            let distanceY = abs(viewPrismPointY - keyPointY)

            var diagDistance = sqrt(pow(distanceX, 2) + pow(distanceY, 2)) / maxRadius
            while diagDistance > 1.0 { diagDistance -= 1.0 }
            let totalDistance = diagDistance
            let pulseWidth = (CGFloat(effect.pulse) / 100)
            var directionDelta = totalDistance / pulseWidth
            while directionDelta > 1.0 { directionDelta -= 1.0 }
            guard let headColor = colorAndLocation.filter({ $0.1 <= directionDelta }).last else { return }
            guard let headIndex = colorAndLocation.firstIndex(where: { $0 == headColor }) else { return }
            guard let tailColor = colorAndLocation.filter({ $0.1 > directionDelta }).first ??
                    colorAndLocation.first.map({($0.0, $0.1 + 1.0)}) else { return }

            let colorLocation = MathUtils.map(value: directionDelta,
                                              inMin: headColor.1,
                                              inMax: tailColor.1,
                                              outMin: 0.0,
                                              outMax: 1.0)

            beforeColor = PrismColor.linearGradient(fromColor: headColor.0.color,
                                                         toColor: tailColor.0.color,
                                                         percent: colorLocation).cgColor

            // Gets closest transition

            let targetColor: PrismRGB
            let distanceLeft: CGFloat
            let targetIndex: Int
            if effect.control == .inward {
                targetColor = tailColor.0.color
                targetIndex = headIndex + 1 < colorAndLocation.count ? headIndex + 1 : 0
                distanceLeft = CGFloat(headColor.0.duration) - (CGFloat(headColor.0.duration) * colorLocation)
            } else {
                if directionDelta > headColor.1 {
                    targetIndex = headIndex
                    targetColor = headColor.0.color
                    distanceLeft = CGFloat(headColor.0.duration) * colorLocation
                } else {
                    targetIndex = headIndex - 1 >= 0 ? headIndex - 1 : colorAndLocation.count - 1
                    targetColor = colorAndLocation[targetIndex].0.color
                    distanceLeft = CGFloat(colorAndLocation[targetIndex].0.duration)
                }
            }

            afterColor = targetColor.cgColor
            durationAnimation = CFTimeInterval(distanceLeft / 100.0)
            transitionIndex = targetIndex
            hasSetInitialWaveEffect = true
        } else {
            // Animates to the next transition depending on speed/color/direction
            let currentColor = colorAndLocation[transitionIndex]
            let nextIndex: Int
            if effect.control == .inward {
                nextIndex = transitionIndex + 1 < colorAndLocation.count ? transitionIndex + 1 : 0
            } else {
                nextIndex = transitionIndex - 1 >= 0 ? transitionIndex - 1 : colorAndLocation.count - 1
            }
            beforeColor = currentColor.0.color.cgColor
            afterColor = colorAndLocation[nextIndex].0.color.cgColor
            durationAnimation = CFTimeInterval(CGFloat(currentColor.0.duration) / 100)
            transitionIndex = nextIndex
        }

        createAnimationBackground(fromColor: beforeColor, toColor: afterColor, duration: durationAnimation)
    }

    private func animateLinearWave(effect: PrismEffect, originViewFrame: NSRect, originX: CGFloat, originY: CGFloat) {
        let beforeColor, afterColor: CGColor
        let durationAnimation: CFTimeInterval
        var totalDur: CGFloat = 0

        let colorAndLocation = effect.transitions.compactMap { transition -> (PrismTransition, CGFloat) in
            let val = (transition, totalDur/CGFloat(effect.transitionDuration))
            totalDur += CGFloat(transition.duration)
            return val
        }

        if !hasSetInitialWaveEffect {
            var xDelta = ((frame.origin.x - originViewFrame.origin.x) / originViewFrame.width) - originX
            var yDelta = ((frame.origin.y - originViewFrame.origin.y) / originViewFrame.height) - originY
            if xDelta < 0 { xDelta += 1 }; if yDelta < 0 { yDelta += 1 }
            let pulseWidth = (CGFloat(effect.pulse) / 100)
            var directionDelta = (effect.direction == .xAxis ? xDelta : yDelta) / pulseWidth
            while directionDelta > 1.0 { directionDelta -= 1.0 }
            guard let headColor = colorAndLocation.filter({ $0.1 <= directionDelta }).last else { return }
            guard let headIndex = colorAndLocation.firstIndex(where: { $0 == headColor }) else { return }
            guard let tailColor = colorAndLocation.filter({ $0.1 > directionDelta }).first ??
                    colorAndLocation.first.map({($0.0, $0.1 + 1.0)}) else { return }

            let colorLocation = MathUtils.map(value: directionDelta,
                                              inMin: headColor.1,
                                              inMax: tailColor.1,
                                              outMin: 0.0,
                                              outMax: 1.0)

            beforeColor = PrismColor.linearGradient(fromColor: headColor.0.color,
                                                         toColor: tailColor.0.color,
                                                         percent: colorLocation).cgColor

            // Gets closest transition

            let targetColor: PrismRGB
            let distanceLeft: CGFloat
            let targetIndex: Int
            if (effect.control == .inward && effect.direction == .xAxis) ||
                (effect.control == .outward && effect.direction == .yAxis) {
                targetColor = tailColor.0.color
                targetIndex = headIndex + 1 < colorAndLocation.count ? headIndex + 1 : 0
                distanceLeft = CGFloat(headColor.0.duration) - (CGFloat(headColor.0.duration) * colorLocation)
            } else {
                if directionDelta > headColor.1 {
                    targetIndex = headIndex
                    targetColor = headColor.0.color
                    distanceLeft = CGFloat(headColor.0.duration) * colorLocation
                } else {
                    targetIndex = headIndex - 1 >= 0 ? headIndex - 1 : colorAndLocation.count - 1
                    targetColor = colorAndLocation[targetIndex].0.color
                    distanceLeft = CGFloat(colorAndLocation[targetIndex].0.duration)
                }
            }

            afterColor = targetColor.cgColor
            durationAnimation = CFTimeInterval(distanceLeft / 100.0)
            transitionIndex = targetIndex
            hasSetInitialWaveEffect = true
        } else {
            // Animates to the next transition depending on speed/color/direction
            let currentColor = colorAndLocation[transitionIndex]
            let nextIndex: Int
            if (effect.control == .inward && effect.direction == .xAxis) ||
                (effect.control == .outward && effect.direction == .yAxis) {
                nextIndex = transitionIndex + 1 < colorAndLocation.count ? transitionIndex + 1 : 0
            } else {
                nextIndex = transitionIndex - 1 >= 0 ? transitionIndex - 1 : colorAndLocation.count - 1
            }
            beforeColor = currentColor.0.color.cgColor
            afterColor = colorAndLocation[nextIndex].0.color.cgColor
            durationAnimation = CFTimeInterval(CGFloat(currentColor.0.duration) / 100)
            transitionIndex = nextIndex
        }
        createAnimationBackground(fromColor: beforeColor, toColor: afterColor, duration: durationAnimation)
    }

    private func createAnimationBackground(fromColor: CGColor, toColor: CGColor, duration: CFTimeInterval) {
        guard let baseLayer = layer else {
            return
        }

        baseLayer.removeAllAnimations()

        let animationGroup = CAAnimationGroup()
        animationGroup.delegate = self

        let borderAnimation = CABasicAnimation(keyPath: "sublayers.backgroundLayer.borderColor")
        borderAnimation.fromValue = fromColor
        borderAnimation.toValue = toColor

        let selectionAnimation = CABasicAnimation(keyPath: "sublayers.selectionLayer.backgroundColor")
        selectionAnimation.fromValue = borderAnimation.fromValue
        selectionAnimation.toValue = borderAnimation.toValue

        let dotAnimation = CABasicAnimation(keyPath: "sublayers.dotLayer.backgroundColor")
        dotAnimation.fromValue = selectionAnimation.fromValue
        dotAnimation.toValue = selectionAnimation.toValue

        animationGroup.animations = [selectionAnimation, borderAnimation, dotAnimation]
        animationGroup.duration = duration

        baseLayer.add(animationGroup, forKey: nil)

        if let color = NSColor(cgColor: toColor) {
            self.color = color
        }
    }
    // When appearance change happens

    override func updateLayer() {
        super.updateLayer()
        if effectiveAppearance.name == .darkAqua {
            backgroundLayer.backgroundColor = baseDarkBackground.cgColor
        } else {
            backgroundLayer.backgroundColor = baseLightBackground.cgColor
        }
    }
}

/// From https://stackoverflow.com/a/46691271
extension NSString {
    func drawVerticallyCentered(in rect: CGRect, withAttributes attributes: [NSAttributedString.Key: Any]? = nil) {
        let size = self.size(withAttributes: attributes)
        let centeredRect = CGRect(x: rect.origin.x,
                                  y: rect.origin.y + (rect.size.height-size.height)/2.0,
                                  width: rect.size.width,
                                  height: size.height)
        self.draw(in: centeredRect, withAttributes: attributes)
    }
}

extension NSNotification.Name {
    static let keySelectionChanged = NSNotification.Name("keySelectionChanged")
}
