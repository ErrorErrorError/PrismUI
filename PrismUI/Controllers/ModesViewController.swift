//
//  ModesViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import Cocoa

class ModesViewController: BaseViewController {

    let presetsButton: NSButton = {
        let button = NSButton()
        button.action = #selector(onButtonClicked(_:))
        button.bezelStyle = .rounded
        button.image = NSImage(named: "NSSidebarTemplate")
        return button
    }()

    weak var delegate: ModesViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        (self.view as? NSVisualEffectView)?.material = .windowBackground
        self.view.addSubview(presetsButton)
        presetsButton.target = self
        presetsButton.translatesAutoresizingMaskIntoConstraints = false
        presetsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        presetsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
    }

    @objc func onButtonClicked(_ sender: NSButton) {
        print("button presssed")
        delegate?.didClickOnPresetsButton()
    }
}

protocol ModesViewControllerDelegate: AnyObject {
    func didClickOnPresetsButton()
}
