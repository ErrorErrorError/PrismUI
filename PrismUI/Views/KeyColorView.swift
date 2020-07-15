//
//  KeyView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyColorView: NSView, CALayerDelegate {

    var text: NSString = NSString()
    var color: NSColor = .white {
      willSet(value) {
        layer?.backgroundColor = value.cgColor
        layer?.setNeedsDisplay()
      }
    }

    let textStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }()

    let newLayer: CALayer = {
        let new = CALayer()
        new.cornerRadius = 4.0
        new.borderColor = NSColor.lightGray.cgColor
        new.borderWidth = 2
        new.shadowOffset = CGSize(width: 0, height: -0.5)
        new.shadowColor = NSColor.black.cgColor
        new.shadowRadius = 0
        new.shadowOpacity = 0.2
        new.allowsEdgeAntialiasing = true
        return new
    }()

    init(color: NSColor, text: String) {
        super.init(frame: NSRect.zero)
        self.color = color
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
