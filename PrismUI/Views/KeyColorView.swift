//
//  KeyView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyColorView: ColorView {

    var prismKey: PrismKey! {
        didSet {
            updateAnimation()
        }
    }

    var text: NSString = NSString()

    var transitionIndex = 0
    let textStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }()

    convenience init(text: String, key: PrismKey) {
        self.init()
        self.prismKey = key
        self.text = text as NSString
        color = prismKey.main.nsColor
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let textColor: NSColor = color.isDarkColor ? .white : .black
        let attributes = [NSAttributedString.Key.paragraphStyle: textStyle,
                          NSAttributedString.Key.foregroundColor: textColor]
        text.drawVerticallyCentered(in: dirtyRect,
                                    withAttributes: attributes)
    }
}

// Update Animation
extension KeyColorView: CAAnimationDelegate {

    func updateAnimation() {
        layer?.removeAllAnimations()
        color = prismKey.main.nsColor
        if prismKey.effect != nil {
            transitionIndex = 0
            animateEffect()
        }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.animateEffect()
        }
    }

    @objc func updateTextColorBackground() {
        guard let presentationLayer = self.layer?.presentation() else { return }
        guard let cgColor = presentationLayer.backgroundColor else { return }
        guard let nsColor = NSColor(cgColor: cgColor) else { return }
        self.color = nsColor
    }

    private func animateEffect() {
        guard let waveLayer = layer else {
            return
        }

        guard let effect = prismKey.effect else {
            return
        }

        waveLayer.removeAllAnimations()
        let transitions = effect.transitions
        let previousTransition = transitions[transitionIndex]
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.delegate = self
        animation.fromValue = previousTransition.color.cgColor
        if transitionIndex + 1 < transitions.count {
            transitionIndex += 1
        } else {
            transitionIndex = 0
        }
        let nextTransition = transitions[transitionIndex]
        animation.toValue = nextTransition.color.cgColor
        animation.duration = CFTimeInterval(CGFloat(previousTransition.duration) / 100)
        color = nextTransition.color.nsColor
        waveLayer.add(animation, forKey: #keyPath(CALayer.backgroundColor))
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
