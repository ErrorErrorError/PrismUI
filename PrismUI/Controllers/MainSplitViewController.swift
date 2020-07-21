//
//  MainSplitViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/12/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class MainSplitViewController: NSSplitViewController {

    let presetsViewController = PresetsViewController()
    let modesViewController = ModesViewController()
    let keyboardViewController = KeyboardViewController()

    var sidebarItem: NSSplitViewItem!
    var leftSideItem: NSSplitViewItem!
    var rightSideItem: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setFrameSize(NSSize(width: 1280, height: 720))
        modesViewController.delegate = self

        setupSplitViewItems()
    }

    private func setupSplitViewItems() {
        sidebarItem = NSSplitViewItem(sidebarWithViewController: presetsViewController)
        sidebarItem.isCollapsed = true
        sidebarItem.minimumThickness = 200
        sidebarItem.maximumThickness = 200

        leftSideItem = NSSplitViewItem(contentListWithViewController: modesViewController)
        leftSideItem.minimumThickness = 240
        leftSideItem.maximumThickness = 240

        rightSideItem = NSSplitViewItem(viewController: keyboardViewController)
        splitView.dividerStyle = .thin

        addSplitViewItem(sidebarItem)
        addSplitViewItem(leftSideItem)
        addSplitViewItem(rightSideItem)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        let clicked = presetsViewController.view.bounds.contains(event.locationInWindow)
        if !clicked {
            sidebarItem.animator().isCollapsed = true
        }
    }
}

// MARK: Attempt to hide split view divider
extension MainSplitViewController {
    override func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        return true
    }

    override func splitView(_ splitView: NSSplitView,
                            effectiveRect proposedEffectiveRect: NSRect,
                            forDrawnRect drawnRect: NSRect,
                            ofDividerAt dividerIndex: Int) -> NSRect {
        return NSRect.zero
    }
}

// MARK: ModesViewController delegate
extension MainSplitViewController: ModesViewControllerDelegate {
    func didClickOnPresetsButton() {
        sidebarItem.animator().isCollapsed = !sidebarItem.isCollapsed
    }
}
