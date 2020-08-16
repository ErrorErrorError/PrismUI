//
//  PrismSelector.swift
//  PrismUI
//
//  Created by Erik Bautista on 8/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class PrismSelector: NSView {

    private let strokeWidth: CGFloat = 3

    let shadowColor = CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)

    var color: PrismHSB = PrismHSB(hue: 0, saturation: 0, brightness: 0) {
        didSet {
            superview?.needsDisplay = true
            needsDisplay = true
        }
    }

    var allowsSelection = false

    var selected: Bool = false {
        didSet {
            selected ? delegate?.didSelect(self) : delegate?.didDeselect(self)
            needsDisplay = true
        }
    }

    var dragging: Bool = false

    weak var delegate: PrismSelectionDelegate?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: -2), blur: 3.0, color: shadowColor)
        color.nsColor.setFill()
        context.fillEllipse(in: bounds.insetBy(dx: strokeWidth/2, dy: strokeWidth/2))
        context.restoreGState()

        if selected {
            color.nsColor.darkerColor(percent: 0.5).setStroke()
        } else {
            NSColor.white.setStroke()
        }
        context.setLineWidth(strokeWidth)
        context.strokeEllipse(in: bounds.insetBy(dx: strokeWidth/2, dy: strokeWidth/2))
    }
}

extension PrismSelector {

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        dragging = false
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        dragging = true
        if selected {
            selected = false
        }
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        if allowsSelection && !dragging {
            selected = !selected
        }

        dragging = false
    }
}

protocol PrismSelectionDelegate: AnyObject {
    func didSelect(_ sender: PrismSelector)
    func didDeselect(_ sender: PrismSelector)
}
