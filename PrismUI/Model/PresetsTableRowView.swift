//
//  PresetsTableRowView.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/22/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class PresetsTableRowView: NSTableRowView {

    private var showHideButton: NSButton?

    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited,
                                                          .activeAlways,
                                                          .inVisibleRect],
                                  owner: self,
                                  userInfo: nil)
        addTrackingArea(area)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didAddSubview(_ subview: NSView) {
        super.didAddSubview(subview)
        if let disclosureButton = subview as? NSButton,
           disclosureButton.identifier == NSOutlineView.disclosureButtonIdentifier {
            disclosureButton.setButtonType(.toggle)
            disclosureButton.title = "Show"
            disclosureButton.alternateTitle = "Hide"
            disclosureButton.imagePosition = .noImage
            disclosureButton.bezelStyle = .inline
            disclosureButton.image = nil
            disclosureButton.alternateImage = nil
            disclosureButton.frame = NSRect(x: frame.width - 46, y: 4, width: 40, height: 15)
            disclosureButton.alphaValue = 0.0
            showHideButton = disclosureButton
        }
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        showHideButton?.animator().alphaValue = 1
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        showHideButton?.animator().alphaValue = 0.0
    }
}
