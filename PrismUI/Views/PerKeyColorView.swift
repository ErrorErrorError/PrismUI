//
//  KeyView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class PerKeyColorView: ColorView {

    static let now = CACurrentMediaTime()

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
            layer?.setNeedsDisplay()
            needsDisplay = true
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

        textView.stringValue = text
        textView.font = NSFont.boldSystemFont(ofSize: 14)
        textView.alignment = .center
        addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
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

extension PerKeyColorView: CAAnimationDelegate {

    func removeAnimation() {
        guard let baseLayer = layer else { return }
        baseLayer.removeAnimation(forKey: "perKeyEffectAnimation")
    }

    func updateAnimation() {
        color = prismKey.main.nsColor
        removeAnimation()
        transitionIndex = 0
        hasSetInitialWaveEffect = false
        if let effect = prismKey.effect {
            if effect.waveActive {
                animateWave()
            } else {
                animationGradient()
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
                self.animationGradient()
            }
        }
    }

    private func animationGradient() {
        guard let effect = prismKey.effect else {
            return
        }
        if transitionIndex >= effect.transitions.count { transitionIndex = 0 }

        let transitionDuration = CGFloat(effect.transitionDuration)
        let transitions = effect.transitions
        let currentTransition = transitions[transitionIndex]
        transitionIndex + 1 < transitions.count ? (transitionIndex += 1) : (transitionIndex = 0)
        let nextTransition = transitions[transitionIndex]
        var deltaPosition = nextTransition.position - currentTransition.position
        if deltaPosition < 0 { deltaPosition += 1.0 }
        let duration = deltaPosition * transitionDuration
        createAnimationBackground(fromColor: currentTransition.color.cgColor,
                                  toColor: nextTransition.color.cgColor,
                                  duration: CFTimeInterval(duration / 100))
    }

    private func animateWave() {
        guard let originViewFrame = superview?.subviews.filter({ $0 is OriginEffectView }).first?.frame else { return }
        guard let effect = prismKey.effect else { return }
        let originXFloat = effect.origin.xPoint
        let originYFloat = 1 - effect.origin.yPoint
        let beforeColor, afterColor: CGColor
        let durationAnimation: CFTimeInterval
        let totalDuration = CGFloat(effect.transitionDuration)
        let transitions = effect.transitions

        if !hasSetInitialWaveEffect {
            var directionDelta: CGFloat

            let keyPointX = (frame.origin.x - originViewFrame.origin.x) + (frame.width / 2)
            let keyPointY = (frame.origin.y - originViewFrame.origin.y) + (frame.height / 2)
            let pulseWidth = (CGFloat(effect.pulse) / 100)

            if effect.direction == .xyAxis {
                let maxRadius = originViewFrame.height

                let distanceX = abs((originXFloat * originViewFrame.width) - keyPointX)
                let distanceY = abs((originYFloat * originViewFrame.height) - keyPointY)

                let diagDistance = sqrt(pow(distanceX, 2) + pow(distanceY, 2)) / maxRadius

                directionDelta = diagDistance / pulseWidth
            } else {
                var xDelta = abs((keyPointX / originViewFrame.width) - originXFloat)
                var yDelta = abs((keyPointY / originViewFrame.height) - originYFloat)
                if xDelta < 0 { xDelta += 1 }; if yDelta < 0 { yDelta += 1 }
                directionDelta = (effect.direction == .xAxis ? xDelta : yDelta) / pulseWidth
            }

            while directionDelta > 1.0 { directionDelta -= 1.0 }
            guard let headColor = transitions.filter({ $0.position <= directionDelta }).last ??
                    transitions.last.map({ PrismTransition(color: $0.color,
                                                           position: $0.position - 1.0) }) else { return }
            let headIndex = transitions.firstIndex(where: { $0 == headColor }) ?? transitions.count - 1
            guard let tailColor = transitions.filter({ $0.position > directionDelta }).first ??
                    transitions.first.map({ PrismTransition(color: $0.color,
                                                            position: $0.position + 1.0) }) else { return }

            let colorLocation = MathUtils.map(value: directionDelta,
                                              inMin: headColor.position,
                                              inMax: tailColor.position,
                                              outMin: 0.0,
                                              outMax: 1.0)

            beforeColor = PrismColor.linearGradient(fromColor: headColor.color,
                                                    toColor: tailColor.color,
                                                    percent: colorLocation).cgColor

            var distanceLeft: CGFloat

            if effect.control == .inward {
                afterColor = tailColor.color.cgColor
                distanceLeft = tailColor.position - directionDelta
                transitionIndex = headIndex + 1 < transitions.count ? headIndex + 1 : 0
            } else {
                afterColor = headColor.color.cgColor
                distanceLeft = directionDelta - headColor.position
                transitionIndex = headIndex
            }
            if distanceLeft < 0 { distanceLeft += 1.0 }

            durationAnimation = CFTimeInterval((distanceLeft * totalDuration) / 100.0)
            hasSetInitialWaveEffect = true
        } else {
            if transitionIndex >= effect.transitions.count { transitionIndex = 0 }
            let currentColor = transitions[transitionIndex]
            let nextIndex: Int
            var distanceDelta: CGFloat = 0
            if effect.control == .inward {
                nextIndex = transitionIndex + 1 < transitions.count ? transitionIndex + 1 : 0
                distanceDelta = transitions[nextIndex].position - currentColor.position
            } else {
                nextIndex = transitionIndex - 1 >= 0 ? transitionIndex - 1 : transitions.count - 1
                distanceDelta = currentColor.position - transitions[nextIndex].position
            }

            if distanceDelta < 0 { distanceDelta += 1.0 }

            beforeColor = currentColor.color.cgColor
            afterColor = transitions[nextIndex].color.cgColor
            durationAnimation = CFTimeInterval((distanceDelta * totalDuration) / 100)
            transitionIndex = nextIndex
        }
        createAnimationBackground(fromColor: beforeColor, toColor: afterColor, duration: durationAnimation)
    }

    private func createAnimationBackground(fromColor: CGColor, toColor: CGColor, duration: CFTimeInterval) {
        guard let baseLayer = layer else {
            return
        }

        removeAnimation()

        let animationGroup = CAAnimationGroup()
        animationGroup.delegate = self

        let borderAnimation = CABasicAnimation(keyPath: "sublayers.backgroundLayer.borderColor")
        borderAnimation.fromValue = fromColor
        borderAnimation.toValue = toColor

        let selectionAnimation = CABasicAnimation(keyPath: "sublayers.selectionLayer.backgroundColor")
        selectionAnimation.fromValue = fromColor
        selectionAnimation.toValue = toColor

        let dotAnimation = CABasicAnimation(keyPath: "sublayers.dotLayer.backgroundColor")
        dotAnimation.fromValue = fromColor
        dotAnimation.toValue = toColor

        animationGroup.duration = duration
        animationGroup.animations = [selectionAnimation, borderAnimation, dotAnimation]

        baseLayer.add(animationGroup, forKey: "perKeyEffectAnimation")

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

extension NSNotification.Name {
    static let keySelectionChanged = NSNotification.Name("keySelectionChanged")
}
