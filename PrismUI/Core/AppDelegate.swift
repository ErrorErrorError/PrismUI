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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var topLevelObjects: NSArray? = []
        Bundle.main.loadNibNamed("MainMenu", owner: self, topLevelObjects: &topLevelObjects)
        guard let menu = topLevelObjects?.filter({ $0 is NSMenu }).first as? NSMenu else {
            let alert = NSAlert()
            alert.addButton(withTitle: "Exit")
            alert.alertStyle = .critical
            alert.messageText = "Menu not loaded."
            alert.informativeText = "There was an error trying to load menu."
            alert.runModal()
            alert.showsSuppressionButton = true
            NSApp.terminate(nil)
            return
        }

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
