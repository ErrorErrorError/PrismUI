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

    var color: NSColor = .red {
      didSet {
        layer?.backgroundColor = color.cgColor
      }
    }

    var selected = false {
        didSet {
            if selected {
                delegate?.didSelect(self)
                layer?.borderColor = NSColor(hue: 0.0,
                                             saturation: 0.0,
                                             brightness: color.isDarkColor ? 1.0 : 0.0,
                                             alpha: 0.5).cgColor
            } else {
                delegate?.didDeselect(self)
                layer?.borderColor = NSColor.gray.cgColor
            }
            layer?.borderWidth = selected ? 5 : 1
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
        layer?.delegate = self
        layer?.backgroundColor = color.cgColor
        layer?.setNeedsDisplay()
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
