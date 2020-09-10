//
//  NotSupportedViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/9/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

public class NotSupportedViewController: BaseViewController {

    let label = NSTextField(labelWithString: "This device is currently not supported.")

    public override func viewDidLoad() {
        label.font = NSFont.systemFont(ofSize: 24)
        (self.view as? NSVisualEffectView)?.material = .contentBackground
        view.addSubview(label)
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

extension String {
    static let notSupported = NSLocalizedString("This device is currently not supported.", comment: "")
    static let noDevicesAvaliable = NSLocalizedString("There are no devices available.", comment: "")
    static let noDeviceSelected = NSLocalizedString("There is no device selected.", comment: "")

}
