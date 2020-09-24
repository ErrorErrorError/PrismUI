//
//  PresetsOutlineView.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/22/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class PresetsOutlineView: NSOutlineView {

    override func menu(for event: NSEvent) -> NSMenu? {
        let point = convert(event.locationInWindow, from: nil)
        let row = self.row(at: point)
        let item = (self.item(atRow: row) as? NSTreeNode)?.representedObject as? PrismPreset
        guard let pItem = item  else { return nil }
        return (pItem.type == .customPreset && !pItem.isDirectory) ? super.menu(for: event) : nil
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let row = self.row(at: point)
        let item = (self.item(atRow: row) as? NSTreeNode)?.representedObject as? PrismPreset
        return (item != nil) ? super.mouseDown(with: event) : deselectAll(nil)
    }
}
