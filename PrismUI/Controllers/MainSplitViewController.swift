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

    var sidebarItem: NSSplitViewItem!
    var leftSideItem: NSSplitViewItem!
    var rightSideItem: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setFrameSize(NSSize(width: 1380, height: 720))
        modesViewController.delegate = self

        setupSplitViewItems()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMainDeviceChanged(_:)),
                                               name: .prismCurrentDeviceChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDeviceRemoved(_:)),
                                               name: .prismDeviceRemoved,
                                               object: nil)
    }

    private func setupSplitViewItems() {
        sidebarItem = NSSplitViewItem(sidebarWithViewController: presetsViewController)
        sidebarItem.isCollapsed = true
        sidebarItem.minimumThickness = 200
        sidebarItem.maximumThickness = 200

        leftSideItem = NSSplitViewItem(contentListWithViewController: modesViewController)
        leftSideItem.minimumThickness = 300
        leftSideItem.maximumThickness = 300

        guard let device = PrismDriver.shared.currentDevice else { return }
        var viewController: NSViewController?
        if device.isKeyboardDevice {
            viewController = KeyboardViewController()
        } else {
            return
        }

        rightSideItem = NSSplitViewItem(viewController: viewController!)
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

// MARK: Observe device changes

extension MainSplitViewController {

    @objc private func onMainDeviceChanged(_ notification: NSNotification) {
        guard let device = notification.object as? PrismDevice else { return }
        if device.isKeyboardDevice {
            if !(rightSideItem.viewController is KeyboardViewController) {
                removeSplitViewItem(rightSideItem)
                rightSideItem = NSSplitViewItem(viewController: KeyboardViewController())
                addSplitViewItem(rightSideItem)
            }
            Log.debug("perKeyDevice loading keyboard")
        } else {
            Log.debug("device not implemented \(device.model)")
        }
    }

    @objc private func onDeviceRemoved(_ notification: NSNotification) {

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
