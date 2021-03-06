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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainWindow: NSWindow = {
            let window = NSWindow()
            window.setContentSize(NSSize(width: 1380, height: 720))
            window.title = "PrismUI"
            window.titlebarAppearsTransparent = true
            window.styleMask.insert([.miniaturizable, .closable, .titled, .fullSizeContentView])
            window.backingType = .buffered
            window.makeKeyAndOrderFront(nil)
            window.center()
            return window
        }()

        NSApplication.shared.mainMenu = menu
        mainWindow.delegate = self
        let splitViewController = MainSplitViewController()
        mainWindow.contentViewController = splitViewController
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
