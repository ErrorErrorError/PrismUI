//
//  MainWindowController.swift
//  PrismUI
//
//  Created by Erik Bautista on 6/15/21.
//  Copyright © 2021 ErrorErrorError. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()

        let toolbar = NSToolbar(identifier: "MainWindowToolbar")
        toolbar.delegate = self
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.displayMode = .default

        window?.toolbar = toolbar

        if #available(macOS 11.0, *) {
            window?.toolbarStyle = .unified
        }

        toolbar.validateVisibleItems()
    }
}

// MARK: Toolbar delegate

extension MainWindowController: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        if itemIdentifier == .cursorSegment {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)

            toolbarItem.label = "Cursor Type"

            var cursorSingle: NSImage!
            var cursorMulti: NSImage!

            if #available(macOS 11.0, *) {
                cursorSingle = NSImage(systemSymbolName: "cursorarrow", accessibilityDescription: "select multi")
                cursorMulti = NSImage(systemSymbolName: "cursorarrow.rays", accessibilityDescription: "select same")
            } else {
                cursorSingle = NSImage(named: "cursorarrow")
                cursorMulti = NSImage(named: "cursorarrow.rays")
            }

            let segmentedControl = NSSegmentedControl(images: [cursorSingle, cursorMulti],
                                                      trackingMode: .selectOne,
                                                      target: self,
                                                      action: #selector(handleSegmentChanged))
            segmentedControl.selectedSegment = 0
            toolbarItem.view = segmentedControl

            return toolbarItem
        }

        return nil
    }

    var orderToolbar: [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .cursorSegment]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return orderToolbar
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return orderToolbar
    }
}

extension MainWindowController {
    @objc func handleSegmentChanged() {
        print("ohhhhh")
    }
}

extension NSToolbarItem.Identifier {
    static let cursorSegment = NSToolbarItem.Identifier("mouse-segment-cursor")
}
