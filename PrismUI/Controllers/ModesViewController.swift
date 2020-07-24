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

    let modesLabel: NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        label.drawsBackground = false
        label.stringValue = "EFFECT"
        label.isBezeled = false
        label.isBordered = false
        label.textColor = NSColor.headerTextColor
        label.font = NSFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let modesPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.addItem(withTitle: "Steady")
        popup.addItem(withTitle: "ColorShift")
        popup.addItem(withTitle: "Breathing")
        popup.addItem(withTitle: "Reactive")
        popup.addItem(withTitle: "Disabled")
        popup.addItem(withTitle: "Mixed")
        popup.item(withTitle: "Mixed")?.isHidden = true
        popup.action = #selector(didModesPopupChanged(_:))
        return popup
    }()

    let colorPicker: PrismColorPicker = PrismColorPicker()

    weak var delegate: ModesViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainView = view as? NSVisualEffectView {
            mainView.material = .windowBackground
            if let colorPickerView = colorPicker.view as? NSVisualEffectView {
                colorPickerView.material = mainView.material
            }
        }

        presetsButton.target = self
        modesPopUp.target = self
        colorPicker.delegate = self
        view.addSubview(presetsButton)
        view.addSubview(modesLabel)
        view.addSubview(modesPopUp)

        addChild(colorPicker)
        view.addSubview(colorPicker.view)
        setupConstraints()
    }

    private func setupConstraints() {
        view.subviews.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        let edgeMargin: CGFloat = 18
        presetsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        presetsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeMargin).isActive = true

        modesLabel.topAnchor.constraint(equalTo: presetsButton.bottomAnchor, constant: 20).isActive = true
        modesLabel.leadingAnchor.constraint(equalTo: presetsButton.leadingAnchor).isActive = true

        modesPopUp.topAnchor.constraint(equalTo: modesLabel.bottomAnchor, constant: 4).isActive = true
        modesPopUp.leadingAnchor.constraint(equalTo: modesLabel.leadingAnchor).isActive = true

        colorPicker.view.topAnchor.constraint(equalTo: modesPopUp.bottomAnchor, constant: 20).isActive = true
        colorPicker.view.leadingAnchor.constraint(equalTo: modesPopUp.leadingAnchor).isActive = true
        colorPicker.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeMargin).isActive = true
        colorPicker.view.heightAnchor.constraint(equalToConstant: 180).isActive = true
    }

    @objc func onButtonClicked(_ sender: NSButton) {
        print("button presssed")
        delegate?.didClickOnPresetsButton()
    }

    @objc func didModesPopupChanged(_ sender: NSPopUpButton) {
        print("sender: \(String(describing: sender.titleOfSelectedItem))")
    }
}

extension ModesViewController: PrismColorPickerDelegate {
    func didColorChange(newColor: PrismRGB, finishedChanging: Bool) {
    }
}

protocol ModesViewControllerDelegate: AnyObject {
    func didClickOnPresetsButton()
}
