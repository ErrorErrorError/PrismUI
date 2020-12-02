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
        color = prismKey.main.nsColor
        if prismKey.effect != nil {
            transitionIndex = 0
            animate()
        } else {
            layer?.removeAllAnimations()
        }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.animate()
        }
    }

    private func animate() {
        guard let baseLayer = layer else {
            return
        }

        guard let effect = prismKey.effect else {
            return
        }

        baseLayer.removeAnimation(forKey: "groupEffect")

        let transitions = effect.transitions
        let previousTransition = transitions[transitionIndex]
        transitionIndex + 1 < transitions.count ? (transitionIndex += 1) : (transitionIndex = 0)
        let nextTransition = transitions[transitionIndex]

        let animationGroup = CAAnimationGroup()
        animationGroup.delegate = self

        let borderAnimation = CABasicAnimation(keyPath: "sublayers.backgroundLayer.borderColor")
        borderAnimation.fromValue = previousTransition.color.cgColor
        borderAnimation.toValue = nextTransition.color.cgColor

        let selectionAnimation = CABasicAnimation(keyPath: "sublayers.selectionLayer.backgroundColor")
        selectionAnimation.fromValue = borderAnimation.fromValue
        selectionAnimation.toValue = borderAnimation.toValue

        let dotAnimation = CABasicAnimation(keyPath: "sublayers.dotLayer.backgroundColor")
        dotAnimation.fromValue = selectionAnimation.fromValue
        dotAnimation.toValue = selectionAnimation.toValue

        animationGroup.animations = [selectionAnimation, borderAnimation, dotAnimation]
        animationGroup.duration = CFTimeInterval(CGFloat(previousTransition.duration) / 100)

        color = nextTransition.color.nsColor

        baseLayer.add(animationGroup, forKey: "groupEffect")
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
