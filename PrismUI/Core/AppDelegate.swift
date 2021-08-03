//
//  AppDelegate.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/12/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    let driver = PrismDriver.shared

    private let menu: NSMenu = AppMenu()

    private let window: NSWindow = {
        let window = NSWindow()
        window.setContentSize(NSSize(width: 1380, height: 720))
        window.title = "PrismUI"
        window.styleMask = [.titled,
                            .closable,
                            .miniaturizable,
                            .unifiedTitleAndToolbar,
                            .fullSizeContentView]
        window.backingType = .buffered
        window.showsToolbarButton = true
        window.makeKeyAndOrderFront(nil)
        return window
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared.mainMenu = menu

        let splitViewController = MainViewController()
        window.contentViewController = splitViewController
        window.delegate = self

        let windowController = MainWindowController(window: window)
        windowController.showWindow(nil)
        windowController.windowDidLoad()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        driver.stop()
    }
}

extension AppDelegate: NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(nil)
    }
}
