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

    // Keys array

    static let keyArray = NSMutableArray()

    // Selector array

    static let selectorArray = NSMutableArray()

    // MARK: Common initialization

    let presetsButton: NSButton = {
        let button = NSButton()
        button.action = #selector(onButtonClicked(_:))
        button.bezelStyle = .rounded
        button.image = NSImage(named: "NSSidebarTemplate")
        return button
    }()

    let modesLabel: NSTextField = {
        let label = NSTextField(labelWithString: "EFFECT")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let modesPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.addItem(withTitle: PrismModes.steady.rawValue)
        popup.addItem(withTitle: PrismModes.colorShift.rawValue)
        popup.addItem(withTitle: PrismModes.breathing.rawValue)
        popup.addItem(withTitle: PrismModes.reactive.rawValue)
        popup.addItem(withTitle: PrismModes.disabled.rawValue)
        popup.addItem(withTitle: PrismModes.mixed.rawValue)
        popup.item(withTitle: PrismModes.mixed.rawValue)?.isHidden = true
        popup.action = #selector(didModesPopupChanged(_:))
        return popup
    }()

    let colorPicker: PrismColorPicker = PrismColorPicker()

    let speedText: NSTextField = {
        let label = NSTextField(labelWithString: "Speed")
        label.setAsLabel()
        return label
    }()

    let speedSlider: NSSlider = {
       let slider = NSSlider()
        slider.isHidden = true
        return slider
    }()

    // MARK: ColorShift and Breathing

    let multiSlider: PrismMultiSliderView = {
        let slider = PrismMultiSliderView()
        slider.isHidden = true
        return slider
    }()

    // MARK: Reactive initialization

    let reactActiveText: NSTextField = {
        let label = NSTextField(labelWithString: "Active")
        label.setAsLabel()
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
        let label = NSTextField(labelWithString: "Rest")
        label.setAsLabel()
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
        multiSlider.selectorDelegate = self
//        reactActiveColor.delegate = self
//        reactRestColor.delegate = self
        view.addSubview(presetsButton)
        view.addSubview(modesLabel)
        view.addSubview(modesPopUp)
        view.addSubview(multiSlider)
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

        // ColorShift cconstraints

        multiSlider.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        multiSlider.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
        multiSlider.topAnchor.constraint(equalTo: colorPicker.view.bottomAnchor).isActive = true
        multiSlider.heightAnchor.constraint(equalToConstant: heightView).isActive = true

    }

    @objc func onButtonClicked(_ sender: NSButton) {
        print("button presssed")
        delegate?.didClickOnPresetsButton()
    }

    @objc func didModesPopupChanged(_ sender: NSPopUpButton) {
        print("sender: \(String(describing: sender.titleOfSelectedItem))")
        switch sender.titleOfSelectedItem {
        case PrismModes.steady.rawValue:
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
        case PrismModes.reactive.rawValue:
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showReactiveMode()
        case PrismModes.colorShift.rawValue:
            showReactiveMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showColorShiftMode()
        case PrismModes.breathing.rawValue:
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode()
        case PrismModes.disabled.rawValue:
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
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

    private func showColorShiftMode(shouldShow: Bool = true) {
        if shouldShow { multiSlider.mode = .colorShift }
        multiSlider.isHidden = !shouldShow
    }

    private func showBreadingMode(shouldShow: Bool = true) {
        if shouldShow { multiSlider.mode = .breathing }
        multiSlider.isHidden = !shouldShow
    }
}

extension ModesViewController: PrismColorPickerDelegate {
    func didColorChange(newColor: PrismRGB, finishedChanging: Bool) {
        switch modesPopUp.titleOfSelectedItem {
        case PrismModes.steady.rawValue:
            ModesViewController.keyArray.filter { ($0 as? ColorView) != nil }.forEach {
                guard let colorView = $0 as? ColorView else { return }
                colorView.color = newColor.nsColor
            }
        case PrismModes.colorShift.rawValue,
             PrismModes.breathing.rawValue:
            ModesViewController.selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
                guard let selector = $0 as? PrismSelector else { return }
                selector.color = newColor.toHSV()
            }
        default:
            break
        }
    }
}

extension ModesViewController: PrismSelectionDelegate {

    func didSelect(_ sender: PrismSelector) {
        ModesViewController.selectorArray.add(sender)
    }

    func didDeselect(_ sender: PrismSelector) {
        ModesViewController.selectorArray.remove(sender)
    }
}

protocol ModesViewControllerDelegate: AnyObject {
    func didClickOnPresetsButton()
}
