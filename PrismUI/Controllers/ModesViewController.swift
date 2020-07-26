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

    // MARK: Common initialization

    let presetsButton: NSButton = {
        let button = NSButton()
        button.action = #selector(onButtonClicked(_:))
        button.bezelStyle = .rounded
        button.image = NSImage(named: "NSSidebarTemplate")
        return button
    }()

    let modesLabel: NSTextField = {
        let label = NSTextField()
        label.setAsLabel()
        label.textColor = NSColor.headerTextColor
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.stringValue = "EFFECT"
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

    let speedText: NSTextField = {
        let label = NSTextField()
        label.setAsLabel()
        label.stringValue = "Speed"
        return label
    }()

    let speedSlider: NSSlider = {
       let slider = NSSlider()
        slider.isHidden = true
        return slider
    }()

    // MARK: Reactive initialization

    let reactActiveText: NSTextField = {
        let label = NSTextField()
        label.setAsLabel()
        label.stringValue = "Active"
        label.isHidden = true
        return label
    }()

    let reactActiveColor: ColorView = {
       let view = ColorView()
        view.isHidden = true
        view.color = PrismRGB(red: 1.0, green: 0.0, blue: 0.0).nsColor
        return view
    }()

    let reactRestText: NSTextField = {
        let label = NSTextField()
        label.setAsLabel()
        label.stringValue = "Rest"
        label.isHidden = true
        return label
    }()

    let reactRestColor: ColorView = {
       let view = ColorView()
        view.isHidden = true
        view.color = PrismRGB(red: 0.0, green: 0.0, blue: 0.0).nsColor
        return view
    }()

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
//        reactActiveColor.delegate = self
//        reactRestColor.delegate = self
        view.addSubview(presetsButton)
        view.addSubview(modesLabel)
        view.addSubview(modesPopUp)
        view.addSubview(reactActiveText)
        view.addSubview(reactActiveColor)
        view.addSubview(reactRestText)
        view.addSubview(reactRestColor)

        addChild(colorPicker)
        view.addSubview(colorPicker.view)
        setupConstraints()
    }

    private func setupConstraints() {
        view.subviews.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        let edgeMargin: CGFloat = 18

        presetsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeMargin).isActive = true
        presetsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true

        modesLabel.leadingAnchor.constraint(equalTo: presetsButton.leadingAnchor).isActive = true
        modesLabel.topAnchor.constraint(equalTo: presetsButton.bottomAnchor, constant: 20).isActive = true

        modesPopUp.leadingAnchor.constraint(equalTo: modesLabel.leadingAnchor).isActive = true
        modesPopUp.topAnchor.constraint(equalTo: modesLabel.bottomAnchor, constant: 4).isActive = true

        colorPicker.view.leadingAnchor.constraint(equalTo: modesPopUp.leadingAnchor).isActive = true
        colorPicker.view.topAnchor.constraint(equalTo: modesPopUp.bottomAnchor, constant: 20).isActive = true
        colorPicker.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeMargin).isActive = true
        colorPicker.view.heightAnchor.constraint(equalToConstant: 180).isActive = true

        // Reactive Constraints
        let heightView: CGFloat = 40
        reactActiveColor.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        reactActiveColor.topAnchor.constraint(equalTo: colorPicker.view.bottomAnchor).isActive = true
        reactActiveColor.widthAnchor.constraint(equalToConstant: heightView).isActive = true
        reactActiveColor.heightAnchor.constraint(equalToConstant: heightView).isActive = true

        reactActiveText.leadingAnchor.constraint(equalTo: reactActiveColor.trailingAnchor, constant: 10).isActive = true
        reactActiveText.centerYAnchor.constraint(equalTo: reactActiveColor.centerYAnchor).isActive = true

        reactRestColor.leadingAnchor.constraint(equalTo: reactActiveText.trailingAnchor, constant: 20).isActive = true
        reactRestColor.topAnchor.constraint(equalTo: reactActiveColor.topAnchor).isActive = true
        reactRestColor.widthAnchor.constraint(equalTo: reactActiveColor.widthAnchor).isActive = true
        reactRestColor.heightAnchor.constraint(equalTo: reactActiveColor.heightAnchor).isActive = true

        reactRestText.leadingAnchor.constraint(equalTo: reactRestColor.trailingAnchor, constant: 10).isActive = true
        reactRestText.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
        reactRestText.centerYAnchor.constraint(equalTo: reactRestColor.centerYAnchor).isActive = true

        // Color
    }

    @objc func onButtonClicked(_ sender: NSButton) {
        print("button presssed")
        delegate?.didClickOnPresetsButton()
    }

    @objc func didModesPopupChanged(_ sender: NSPopUpButton) {
        print("sender: \(String(describing: sender.titleOfSelectedItem))")
        switch sender.titleOfSelectedItem {
        case "Steady":
            showReactiveMode(shouldShow: false)
        case "Reactive":
            showReactiveMode()
        default:
            Log.error("Mode Unavalilable")
        }
    }
}

extension ModesViewController {

    private func showReactiveMode(shouldShow: Bool = true) {
        reactActiveText.isHidden = !shouldShow
        reactActiveColor.isHidden = !shouldShow
        reactRestText.isHidden = !shouldShow
        reactRestColor.isHidden = !shouldShow
    }

}

extension ModesViewController: PrismColorPickerDelegate {
    func didColorChange(newColor: PrismRGB, finishedChanging: Bool) {

    }
}

protocol ModesViewControllerDelegate: AnyObject {
    func didClickOnPresetsButton()
}
