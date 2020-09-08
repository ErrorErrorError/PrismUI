//
//  PrismSelector.swift
//  PrismUI
//
//  Created by Erik Bautista on 8/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class PrismSelector: NSView {

    let strokeWidth: CGFloat = 3
    var allowsSelection = false
    var dragging: Bool = false
    weak var delegate: PrismSelectorDelegate?
    var selected: Bool = false {
        didSet {
            selected ? delegate?.didSelect(self) : delegate?.didDeselect(self)
            if selected {
                layer?.borderColor = NSColor(hue: 0.0,
                                                 saturation: 0.0,
                                                 brightness: 0.0,
                                                 alpha: 0.5).cgColor
            } else {
                layer?.borderColor = CGColor.white
            }
        }
    }
    var color: PrismHSB = PrismHSB(hue: 0, saturation: 0, brightness: 0) {
        didSet {
            layer?.backgroundColor = color.nsColor.cgColor
            superview?.needsDisplay = true
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.borderColor = CGColor.white
        layer?.cornerRadius = frame.width/2
        layer?.borderWidth = strokeWidth
        layer?.backgroundColor = color.nsColor.cgColor
        self.shadow = NSShadow()
        layer?.shadowColor = CGColor.black
        layer?.shadowOffset = CGSize(width: 0, height: -2)
        layer?.shadowOffset = .zero
        layer?.shadowOpacity = 1.0
        layer?.shadowRadius = 10
        layer?.shadowPath = CGPath(roundedRect: bounds,
                                   cornerWidth: frame.width/2,
                                   cornerHeight: frame.height/2,
                                   transform: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        delegate?.event(self, event)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        if allowsSelection && !dragging {
            selected = !selected
        }

        dragging = false
        delegate?.event(self, event)
    }
}

protocol PrismSelectorDelegate: AnyObject {
    func didSelect(_ sender: PrismSelector)
    func didDeselect(_ sender: PrismSelector)
    func event(_ sender: PrismSelector, _ event: NSEvent)
}
