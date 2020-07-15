//
//  MainSplitViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/12/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class MainSplitViewController: NSSplitViewController {

    let sidebarItem: NSSplitViewItem = {
        let presetsViewController = PresetsViewController()
        let sidebar = NSSplitViewItem(sidebarWithViewController: presetsViewController)
        sidebar.isCollapsed = true
        sidebar.canCollapse = true
        return sidebar
    }()

    let leftSideItem: NSSplitViewItem = {
        let modesViewController = ModesViewController()
        let leftSide = NSSplitViewItem(contentListWithViewController: modesViewController)
        leftSide.canCollapse = false
        leftSide.minimumThickness = 240
        leftSide.maximumThickness = 240
        return leftSide
    }()

    let rightSideItem: NSSplitViewItem = {
        let keyboardViewController = KeyboardViewController()
        let rightSide = NSSplitViewItem(viewController: keyboardViewController)
        rightSide.canCollapse = false
        return rightSide
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setFrameSize(NSSize(width: 1280, height: 720))

        addSplitViewItem(sidebarItem)
        addSplitViewItem(leftSideItem)
        addSplitViewItem(rightSideItem)
    }
}
