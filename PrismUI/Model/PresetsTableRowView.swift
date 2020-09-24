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
        subview.constraints.forEach { $0.isActive = false }

        if let disclosureButton = subview as? NSButton,
            disclosureButton.identifier == NSOutlineView.disclosureButtonIdentifier {
            disclosureButton.isHidden = true
            disclosureButton.removeFromSuperview()

            let newButton = NSButton()
            newButton.target = disclosureButton.target
            newButton.action = disclosureButton.action
            newButton.setButtonType(.toggle)
            self.addSubview(newButton)
            showHideButton = newButton
        } else if let newButton = subview as? NSButton {
            newButton.identifier = NSOutlineView.disclosureButtonIdentifier
            newButton.title = "Show"
            newButton.alternateTitle = "Hide"
            newButton.bezelStyle = .inline
            newButton.font = NSFont.systemFont(ofSize: 11)
            newButton.frame = NSRect(x: frame.width - 46, y: 4, width: 40, height: 15)
            newButton.alphaValue = 0.0
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
