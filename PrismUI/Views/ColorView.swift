//
//  ColorView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/25/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import Cocoa

class ColorView: NSView, CALayerDelegate {

    weak var delegate: ColorViewDelegate?

    var color: NSColor = .white {
      willSet(newValue) {
        layer?.backgroundColor = newValue.cgColor
        if newValue.scaledBrightness < 0.5 {
            layer?.borderColor = NSColor.white.usingColorSpace(.genericRGB)!
                .darkerColor(percent: Double(newValue.scaledBrightness)).cgColor
        } else {
            layer?.borderColor = newValue.darkerColor(percent: 0.5).cgColor
        }
        layer?.setNeedsDisplay()
      }
    }

    var isSelected = false {
        didSet(oldValue) {
            isSelected ? delegate?.didSelect(self) : delegate?.didDeselect(self)
            layer?.borderWidth = isSelected ? 5 : 0
            layer?.setNeedsDisplay()
        }
    }

    let newLayer: CALayer = {
        let new = CALayer()
        new.cornerRadius = 4.0
        new.borderColor = NSColor.lightGray.cgColor
        new.borderWidth = 0
        new.shadowOffset = CGSize(width: 0, height: -0.5)
        new.shadowColor = NSColor.black.cgColor
        new.shadowRadius = 0
        new.shadowOpacity = 0.2
        new.allowsEdgeAntialiasing = true
        return new
    }()

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
        layer = newLayer
        layer!.delegate = self
        layer!.backgroundColor = color.cgColor
        layer!.setNeedsDisplay()
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.isSelected = !isSelected
    }
}

protocol ColorViewDelegate: AnyObject {
    func didSelect(_ sender: ColorView)
    func didDeselect(_ sender: ColorView)
}
