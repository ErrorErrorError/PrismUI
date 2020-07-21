//
//  AppDelegate.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/12/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var prismDriver: PrismDriver?

    let mainWindow: NSWindow = {
        let window = NSWindow()
        window.setContentSize(NSSize(width: 1280, height: 720))
        window.title = "PrismUI"
        window.titlebarAppearsTransparent = true
        window.styleMask.insert([.miniaturizable, .closable, .titled, .fullSizeContentView])
        window.backingType = .buffered
        window.makeKeyAndOrderFront(nil)
        window.center()
        return window
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        prismDriver = PrismDriver.shared
        let splitViewController = MainSplitViewController()
        mainWindow.contentViewController = splitViewController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
