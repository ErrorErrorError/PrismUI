//
//  KeyView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyColorView: NSControl, CALayerDelegate {

    var text: NSString = NSString()

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

    weak var delegate: KeyColorViewDelegate?

    let textStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }()

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

    init(text: String) {
        super.init(frame: NSRect.zero)
        self.text = text as NSString

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

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        text.drawVerticallyCentered(in: dirtyRect, withAttributes: [NSAttributedString.Key.paragraphStyle: textStyle])
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.isSelected = !isSelected
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

protocol KeyColorViewDelegate: AnyObject {
    func didSelect(_ sender: KeyColorView)
    func didDeselect(_ sender: KeyColorView)
}
