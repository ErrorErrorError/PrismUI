//
//  AppMenu.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/8/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa
import Sparkle

class AppMenu: NSMenu {

    private lazy var applicationName = ProcessInfo.processInfo.processName

    convenience init() {
        self.init(title: "")

        let mainMenu = NSMenuItem()
        mainMenu.target = self
        mainMenu.submenu = NSMenu(title: "MainMenu")
        mainMenu.submenu?.items = [NSMenuItem(title: "About \(applicationName)",
                                              action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                                              keyEquivalent: ""),
                                   NSMenuItem(title: "Check for Updates...",
                                              target: self,
                                              action: #selector(checkForUpdates(_:)),
                                              keyEquivalent: ""),
                                   NSMenuItem(title: "Generate Logs...",
                                              target: self,
                                              action: #selector(generateLog(_:)),
                                              keyEquivalent: ""),
                                   NSMenuItem.separator(),
                                   NSMenuItem(title: "Preferences...", action: nil, keyEquivalent: ","),
                                   NSMenuItem.separator(),
                                   NSMenuItem(title: "Hide \(applicationName)",
                                              action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"),
                                   NSMenuItem(title: "Hide Others",
                                              target: self,
                                              action: #selector(NSApplication.hideOtherApplications(_:)),
                                              keyEquivalent: "h"),
                                   NSMenuItem(title: "Show All",
                                              action: #selector(NSApplication.unhideAllApplications(_:)),
                                              keyEquivalent: ""),
                                   NSMenuItem.separator(),
                                   NSMenuItem(title: "Quit \(applicationName)",
                                              action: #selector(NSApplication.shared.terminate(_:)),
                                              keyEquivalent: "q")]
        items = [mainMenu]
    }

    @objc func checkForUpdates(_ sender: NSMenuItem) {
        SUUpdater.shared()?.checkForUpdates(sender)
    }

    @objc func generateLog(_ selector: NSMenuItem) {
        selector.isEnabled = false
        DispatchQueue.global().async {
            BugReporter.generateBugReport()
            DispatchQueue.main.async {
                selector.isEnabled = true
            }
        }
    }
}

extension NSMenuItem {
    convenience init(title string: String,
                     target: AnyObject = self as AnyObject,
                     action selector: Selector?,
                     keyEquivalent charCode: String) {
        self.init(title: string, action: selector, keyEquivalent: charCode)
        self.target = target
    }
}
