//
//  DeviceControlViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 3/7/21.
//  Copyright © 2021 ErrorErrorError. All rights reserved.
//

import Cocoa

class DeviceControlViewController: BaseViewController {

    // MARK: Delegates

    weak var delegate: ModesViewControllerDelegate?

    weak var deviceControlDelegate: PrismDeviceControlDelegate?

    // MARK: Variables

    let edgeMargin: CGFloat = 18

    // MARK: NSViews

    let presetsButton: NSButton = {
        let image = NSImage(named: "NSSidebarTemplate")!
        let button = NSButton(image: image,
                              target: nil,
                              action: #selector(onButtonClicked(_:update:)))
        button.bezelStyle = .rounded
        button.identifier = .presets
        return button
    }()

    let deviceLabel: NSTextField = {
        let label = NSTextField(labelWithString: "DEVICE")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let devicesPopup: NSPopUpButton = {
        let popup = NSPopUpButton(title: "", target: nil, action: #selector(onChangedDevicePopup(_:)))
        return popup
    }()

    let modesLabel: NSTextField = {
        let label = NSTextField(labelWithString: "EFFECT")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let modesPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.action = #selector(onEffectPopupChanged(_:))
        return popup
    }()

    let colorPicker: PrismColorPickerController = PrismColorPickerController()

    let cursorSegment: NSSegmentedControl = {
        let singleSelectImage = NSCursor.arrow.image
        let multiSelectSameImage = NSCursor.pointingHand.image
        let segment = NSSegmentedControl(images: [singleSelectImage,
                                                  multiSelectSameImage],
                                         trackingMode: .selectOne,
                                         target: nil,
                                         action: nil)
        segment.selectedSegment = 0
        return segment
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainView = view as? NSVisualEffectView {
            mainView.material = .underPageBackground
            if let colorPickerView = colorPicker.view as? NSVisualEffectView {
                colorPickerView.material = mainView.material
            }
        }

        presetsButton.target = self
        devicesPopup.target = self
        modesPopUp.target = self
        colorPicker.delegate = self

        view.addSubview(presetsButton)
        view.addSubview(cursorSegment)
        view.addSubview(deviceLabel)
        view.addSubview(devicesPopup)
        view.addSubview(modesLabel)
        view.addSubview(modesPopUp)

        addChild(colorPicker)

        view.addSubview(colorPicker.view)

        initCommonConstraints()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPrismDeviceAdded(_:)),
                                               name: .prismDeviceAdded,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPrismDeviceRemoved(_:)),
                                               name: .prismDeviceRemoved,
                                               object: nil)

        devicesPopup.addItem(withTitle: "No device selected")
        devicesPopup.selectItem(withTitle: "No device selected")

        for deviceName in PrismDriver.shared.devices.compactMap({ ($0 as? PrismDevice)?.name }) {
            devicesPopup.addItem(withTitle: deviceName)
        }
    }

    private func initCommonConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        presetsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeMargin).isActive = true
        presetsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true

        cursorSegment.topAnchor.constraint(equalTo: presetsButton.topAnchor).isActive = true
        cursorSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeMargin).isActive = true

        deviceLabel.leadingAnchor.constraint(equalTo: presetsButton.leadingAnchor).isActive = true
        deviceLabel.topAnchor.constraint(equalTo: presetsButton.bottomAnchor, constant: 20).isActive = true

        devicesPopup.leadingAnchor.constraint(equalTo: deviceLabel.leadingAnchor).isActive = true
        devicesPopup.topAnchor.constraint(equalTo: deviceLabel.bottomAnchor, constant: 4).isActive = true

        modesLabel.leadingAnchor.constraint(equalTo: devicesPopup.leadingAnchor).isActive = true
        modesLabel.topAnchor.constraint(equalTo: devicesPopup.bottomAnchor, constant: 10).isActive = true

        modesPopUp.leadingAnchor.constraint(equalTo: modesLabel.leadingAnchor).isActive = true
        modesPopUp.topAnchor.constraint(equalTo: modesLabel.bottomAnchor, constant: 4).isActive = true

        colorPicker.view.leadingAnchor.constraint(equalTo: modesPopUp.leadingAnchor).isActive = true
        colorPicker.view.topAnchor.constraint(equalTo: modesPopUp.bottomAnchor, constant: 20).isActive = true
        colorPicker.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeMargin).isActive = true
        colorPicker.view.heightAnchor.constraint(equalToConstant: 180).isActive = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                               name: .prismDeviceAdded,
                                               object: nil)

        NotificationCenter.default.removeObserver(self,
                                               name: .prismDeviceRemoved,
                                               object: nil)
    }
}

// MARK: Actions

extension DeviceControlViewController {

    @objc private func onPrismDeviceAdded(_ notification: NSNotification) {
        guard let newDevice = notification.object as? PrismDevice else { return }
        DispatchQueue.main.async {
            if !self.devicesPopup.itemTitles.contains(newDevice.name) {
                self.devicesPopup.addItem(withTitle: newDevice.name)
            }
        }
    }

    @objc private func onPrismDeviceRemoved(_ notification: NSNotification) {
        guard let removeDevice = notification.object as? PrismDevice else { return }
        DispatchQueue.main.async {
            let selectedDevice = PrismDriver.shared.currentDevice
            if selectedDevice == removeDevice {
                PrismDriver.shared.currentDevice = nil
                self.children.filter({ $0 as? PrismColorPickerController == nil}).forEach({ $0.removeFromParent() })
                self.deviceControlDelegate = nil
            }

            self.devicesPopup.removeItem(withTitle: removeDevice.name)
            if self.devicesPopup.itemArray.filter({ !$0.isHidden }).compactMap({ $0.title }).count == 0 {
                Log.debug("Notify controllers that there are no items available.")
                NotificationCenter.default.post(name: .prismSelectedDeviceChanged, object: nil)
            }
        }
    }

    @objc private func onChangedDevicePopup(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem else { return }
        let devices = PrismDriver.shared.devices.compactMap { $0 as? PrismDevice }
        guard let selectedDevice = devices.filter({ $0.name == title }).first else { return }
        devicesPopup.item(withTitle: "No device selected")?.isHidden = true
        updateLayoutWithNewDevice(device: selectedDevice)
        PrismDriver.shared.currentDevice = selectedDevice
        NotificationCenter.default.post(name: .prismSelectedDeviceChanged, object: selectedDevice)
        Log.debug("Changed currently selected device: \(selectedDevice.name)")
    }

    @objc func onButtonClicked(_ sender: NSButton, update: Bool = true) {
        guard let identifier = sender.identifier else { return }

        switch identifier {
        case .presets:
            delegate?.didClickOnPresetsButton()
            return
        default:
            break
        }
    }

    @objc func onEffectPopupChanged(_ sender: NSPopUpButton) {
        deviceControlDelegate?.modesChanged(mode: sender.title, update: true)
    }
}

// MARK: Color Picker delegate

extension DeviceControlViewController: PrismColorPickerDelegate {

    func didColorChange(newColor: PrismRGB, finishedChanging: Bool) {
        deviceControlDelegate?.updateViews(color: newColor, finished: finishedChanging)
    }
}

// MARK: Device functions

extension DeviceControlViewController {

    func updateLayoutWithNewDevice(device: PrismDevice) {
        if device != PrismDriver.shared.currentDevice {
            if device.model == .perKey || device.model == .perKeyGS65 {
                let perKeyLayout = PerKeyControlViewController()
                addChild(perKeyLayout)
                view.addSubview(perKeyLayout.view)
                perKeyLayout.view.translatesAutoresizingMaskIntoConstraints = false
                perKeyLayout.view.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
                perKeyLayout.view.topAnchor.constraint(equalTo: colorPicker.view.bottomAnchor).isActive = true
                perKeyLayout.view.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
                perKeyLayout.view.heightAnchor.constraint(equalToConstant: 200).isActive = true
            } else {
                Log.error("Currently do not have this device implemented: \(device)")
            }
        }
    }
}

// MARK: Button sidebar delegate

protocol ModesViewControllerDelegate: AnyObject {
    func didClickOnPresetsButton()
}

// MARK: Notification broadcast

extension Notification.Name {
    public static let prismSelectedDeviceChanged = Notification.Name(rawValue: "prismSelectedDeviceChanged")
}

extension NSUserInterfaceItemIdentifier {
    static let speed = NSUserInterfaceItemIdentifier(rawValue: "speed-slider")
    static let presets = NSUserInterfaceItemIdentifier(rawValue: "presets")
}

public protocol PrismDeviceControlDelegate: AnyObject {
    func updateViews(color: PrismRGB, finished: Bool)
    func modesChanged(mode: String, update: Bool)
}
