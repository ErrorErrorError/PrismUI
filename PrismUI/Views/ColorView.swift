//
//  ColorView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/25/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import Cocoa

class ColorView: NSView {

    weak var delegate: ColorViewDelegate?

    let cornerRadius: CGFloat = 4.0

    var color: NSColor = .red {
      didSet {
        backgroundLayer.borderColor = NSColor(hue: 0.0,
                                              saturation: 0.0,
                                              brightness: color.isDarkColor ? 1.0 : 0.0,
                                              alpha: 0.5).cgColor
        backgroundLayer.backgroundColor = color.cgColor
        backgroundLayer.setNeedsDisplay()
      }
    }

    var selected = false {
        didSet {
            backgroundLayer.borderWidth = selected ? 4 : 1
            if selected {
                delegate?.didSelect(self)
            } else {
                delegate?.didDeselect(self)
                backgroundLayer.borderColor = NSColor.gray.cgColor
            }
            backgroundLayer.setNeedsDisplay()
        }
    }

    let backgroundLayer = CALayer()

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        let newFrame = NSRect(origin: CGPoint.zero, size: newSize)
        backgroundLayer.frame = newFrame
        layer?.shadowPath = CGPath(roundedRect: newFrame,
                                   cornerWidth: cornerRadius,
                                   cornerHeight: cornerRadius,
                                   transform: nil)
    }

    convenience init() {
        self.init(frame: NSRect.zero)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        wantsLayer = true

        layer?.backgroundColor = CGColor.clear

        // Border Color

        backgroundLayer.borderWidth = 1
        backgroundLayer.backgroundColor = color.cgColor
        backgroundLayer.actions = ["backgroundColor": NSNull()]

        // Corner Radius

        layer?.cornerRadius = cornerRadius
        backgroundLayer.cornerRadius = cornerRadius

        // Shadow

        self.shadow = NSShadow()
        layer?.shadowColor = CGColor.black
        layer?.shadowOffset = .zero
        layer?.shadowOpacity = 0.15
        layer?.shadowRadius = 2
        layer?.shadowOffset = CGSize(width: 0, height: -0.8)

        layer?.allowsEdgeAntialiasing = true
        layer?.addSublayer(backgroundLayer)
        backgroundLayer.setNeedsDisplay()
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.selected = !selected
    }
}

protocol ColorViewDelegate: AnyObject {
    func didSelect(_ sender: ColorView)
    func didDeselect(_ sender: ColorView)
}
