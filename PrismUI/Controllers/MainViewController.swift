//
//  MainSplitViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/12/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class MainViewController: NSSplitViewController {

    let presetsViewController = PresetsViewController()
    let modesViewController = DeviceControlViewController()

    var sidebarItem: NSSplitViewItem!
    var leftSideItem: NSSplitViewItem!
    var rightSideItem: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setFrameSize(NSSize(width: 1460, height: 720))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onSelectedDeviceChanged(_:)),
                                               name: .prismSelectedDeviceChanged,
                                               object: nil)
        setupSplitViewItems()
    }

    private func setupSplitViewItems() {
        sidebarItem = NSSplitViewItem(sidebarWithViewController: presetsViewController)
        sidebarItem.isCollapsed = true
        sidebarItem.minimumThickness = 200
        sidebarItem.maximumThickness = 200

        modesViewController.delegate = self
        leftSideItem = NSSplitViewItem(contentListWithViewController: modesViewController)
        leftSideItem.minimumThickness = 300
        leftSideItem.maximumThickness = 300

        var viewController: NSViewController?

        if PrismDriver.shared.devices.count > 0 {
            viewController = PrismAlertViewController(errorText: .noDeviceSelected)
        } else {
            viewController = PrismAlertViewController(errorText: .noDevicesAvaliable)
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

    deinit {
        NotificationCenter.default.removeObserver(self, name: .prismSelectedDeviceChanged, object: nil)
    }
}

// MARK: Observe device changes

extension MainViewController {

    @objc private func onSelectedDeviceChanged(_ notification: NSNotification) {
        if let device = notification.object as? PrismDevice {
            if device.isKeyboardDevice && device.model != .threeRegion {
                if !(rightSideItem.viewController is KeyboardViewController) {
                    removeSplitViewItem(rightSideItem)
                    rightSideItem = NSSplitViewItem(viewController: KeyboardViewController())
                    addSplitViewItem(rightSideItem)
                }
            } else {
                removeSplitViewItem(rightSideItem)
                rightSideItem = NSSplitViewItem(viewController: PrismAlertViewController())
                addSplitViewItem(rightSideItem)
            }
        } else {
            removeSplitViewItem(rightSideItem)
            rightSideItem = NSSplitViewItem(viewController: PrismAlertViewController(errorText: .noDevicesAvaliable))
            addSplitViewItem(rightSideItem)
        }
    }
}

// MARK: Attempt to hide split view divider

extension MainViewController {
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

extension MainViewController: ModesViewControllerDelegate {
    func didClickOnPresetsButton() {
        sidebarItem.animator().isCollapsed = !sidebarItem.isCollapsed
    }
}
