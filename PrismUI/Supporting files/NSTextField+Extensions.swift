//
//  NSTextField+Extensions.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/25/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

extension NSTextField {

    func setupTextField() {
        self.drawsBackground = false
        self.isEditable = true
        self.isBordered = false
        self.isBezeled = false
        self.font = NSFont.boldSystemFont(ofSize: 14)
        self.refusesFirstResponder = true
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    func setAsLabel() {
        self.isEditable = false
        self.isBezeled = false
        self.isBordered = false
        self.drawsBackground = false
        self.isSelectable = false
        self.textColor = NSColor.secondaryLabelColor
        self.font = NSFont.systemFont(ofSize: 14)
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

}
