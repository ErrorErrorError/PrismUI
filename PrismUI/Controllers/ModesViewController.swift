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

    var updatePending = false

    // MARK: Selector array

    static let selectorArray = NSMutableArray()

    // MARK: Common initialization

    let edgeMargin: CGFloat = 18

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
        popup.action = #selector(didEffectPopupChanged(_:))
        return popup
    }()

    let colorPicker: PrismColorPicker = PrismColorPicker()

    // MARK: Per Key Views

    let speedLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Speed")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()

    let speedSlider: NSSlider = {
        let slider = NSSlider(value: 300,
                             minValue: 100,
                             maxValue: 3000,
                             target: nil,
                             action: #selector(onSliderChanged(_:update:)))
        slider.isHidden = true
        slider.identifier = .speed
        return slider
    }()

    let speedValue: NSTextField = {
        let label = NSTextField(labelWithString: "3s")
        label.isHidden = true
        return label
    }()

    // MARK: ColorShift and Breathing

    let multiSlider: PrismMultiSliderView = {
        let slider = PrismMultiSliderView()
        slider.isHidden = true
        return slider
    }()

    // MARK: ColorShift items

    let waveToggle: NSButton = {
        let check = NSButton(checkboxWithTitle: "Wave Mode",
                             target: nil,
                             action: #selector(onButtonClicked(_:update:)))
        check.state = .on
        check.identifier = .waveToggle
        check.isHidden = true
        return check
    }()

    let originButton: NSButton = {
        let button = NSButton(title: "Origin",
                              target: nil,
                              action: #selector(onButtonClicked(_:update:)))
        button.isHidden = true
        button.identifier = .origin
        return button
    }()

    let waveDirectionControl: NSSegmentedControl = {
        let segmented = NSSegmentedControl(labels: ["XY", "X", "Y"],
                                           trackingMode: .selectOne,
                                           target: nil,
                                           action: #selector(onButtonClicked(_:update:)))
        segmented.selectedSegment = 0
        segmented.identifier = .xyDirection
        segmented.isHidden = true
        return segmented
    }()

    let waveInwardOutwardControl: NSSegmentedControl = {
        let segmented = NSSegmentedControl(labels: ["Out", "In"],
                                           trackingMode: .selectOne,
                                           target: nil,
                                           action: #selector(onButtonClicked(_:update:)))
        segmented.selectedSegment = 0
        segmented.identifier = .inwardOutward
        segmented.isHidden = true
        return segmented
    }()

    let pulseLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Pulse")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()

    let pulseSlider: NSSlider = {
        let slider = NSSlider(value: 100,
                              minValue: 30,
                              maxValue: 1000,
                              target: nil,
                              action: #selector(onSliderChanged(_:update:)))
        slider.isHidden = true
        slider.identifier = .pulse
        return slider
    }()

    let pulseValue: NSTextField = {
        let label = NSTextField(labelWithString: "10")
        label.isHidden = true
        return label
    }()

    // MARK: Reactive initialization

    let reactActiveText: NSTextField = {
        let label = NSTextField(labelWithString: "Active")
        label.setupLabel()
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
        label.setupLabel()
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

    var selectorDragging = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainView = view as? NSVisualEffectView {
            mainView.material = .windowBackground
            if let colorPickerView = colorPicker.view as? NSVisualEffectView {
                colorPickerView.material = mainView.material
            }
        }

        initCommonViews()

        guard let device = PrismDriver.shared.currentDevice else { return }
        if device.isKeyboardDevice {
            if device.model != .threeRegion {
                perKeyLayoutSetup()
            } else {
                // TODO: Setup three region views
            }
        }
    }

    private func initCommonViews() {
        presetsButton.target = self
        modesPopUp.target = self
        colorPicker.delegate = self
        devicesPopup.target = self

        view.addSubview(presetsButton)
        view.addSubview(deviceLabel)
        view.addSubview(devicesPopup)
        view.addSubview(modesLabel)
        view.addSubview(modesPopUp)

        addChild(colorPicker)
        view.addSubview(colorPicker.view)

        for deviceName in PrismDriver.shared.devices.compactMap({ ($0 as? PrismDevice)?.name }) {
            devicesPopup.addItem(withTitle: deviceName)
        }

        if let currentDevice = PrismDriver.shared.currentDevice {
            devicesPopup.selectItem(withTitle: currentDevice.name)
        }

        initCommonConstraints()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPrismDeviceAdded(_:)),
                                               name: .prismDeviceAdded,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPrismDeviceRemoved(_:)),
                                               name: .prismDeviceAdded,
                                               object: nil)
    }

    private func initCommonConstraints() {
        view.subviews.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
        }

        presetsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeMargin).isActive = true
        presetsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true

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
}

// MARK: Actions

extension ModesViewController {

    @objc private func onPrismDeviceAdded(_ notification: NSNotification) {
        print("deviceAdded: \(notification)")
        guard let newDevice = notification.object as? PrismDevice else { return }
        devicesPopup.addItem(withTitle: newDevice.name)
    }

    @objc private func onPrismDeviceRemoved(_ notification: NSNotification) {
        print("deviceAdded: \(notification)")
        guard let removeDevice = notification.object as? PrismDevice else { return }
        devicesPopup.removeItem(withTitle: removeDevice.name)
        if removeDevice.isKeyboardDevice && removeDevice.model != .threeRegion {
            removePerKeySettingsLayout()
        } else {
            // TODO: Remove layout effects
        }
    }

    @objc private func onChangedDevicePopup(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem else { return }
        let devices = PrismDriver.shared.devices.compactMap { $0 as? PrismDevice }
        guard let selectedDevice = devices.filter({ $0.name == title }).first else { return }
        updateLayoutWithNewDevice(device: selectedDevice)
        PrismDriver.shared.currentDevice = selectedDevice
        NotificationCenter.default.post(name: .prismCurrentDeviceChanged, object: selectedDevice)
    }

    @objc func onSliderChanged(_ sender: NSSlider, update: Bool = true) {
        guard let device = PrismDriver.shared.currentDevice else { return }
        if device.isKeyboardDevice && device.model != .threeRegion {
            handlePerKeySliderChanged(sender, update: update)
        } else {
            Log.debug("Did not update slider \(sender.identifier?.rawValue ?? "nil") for " +
                "\(PrismDriver.shared.currentDevice?.name ?? "nil")")
        }
    }

    @objc func onButtonClicked(_ sender: NSButton, update: Bool = true) {
        guard let device = PrismDriver.shared.currentDevice else { return }
        if device.isKeyboardDevice && device.model != .threeRegion {
            handlePerKeyButtonClicked(sender, update: update)
        } else {
            Log.debug("Did not update button \(sender.identifier?.rawValue ?? "nil") for " +
                "\(PrismDriver.shared.currentDevice?.name ?? "nil")")
        }
    }

    @objc func didEffectPopupChanged(_ sender: NSPopUpButton) {
        guard let device = PrismDriver.shared.currentDevice else { return }
        if device.isKeyboardDevice && device.model != .threeRegion {
            handlePerKeyPopup(sender)
        } else {
            Log.debug("Did not update effecct \(sender.identifier?.rawValue ?? "nil") for " +
                "\(PrismDriver.shared.currentDevice?.name ?? "nil")")
        }
    }
}

// MARK: Color Picker delegate

extension ModesViewController: PrismColorPickerDelegate {

    func didColorChange(newColor: PrismRGB, finishedChanging: Bool) {
        guard let device = PrismDriver.shared.currentDevice else {
            return
        }

        if device.isKeyboardDevice && device.model != .threeRegion {
            updatePerKeyColors(newColor: newColor, finished: finishedChanging)
        } else if device.isKeyboardDevice && device.model == .threeRegion {
            // TODO: Update three region keyboard viw
        }
    }
}

// MARK: Device functions

extension ModesViewController {

    func updateLayoutWithNewDevice(device: PrismDevice) {
        if device != PrismDriver.shared.currentDevice {
            removePerKeySettingsLayout()
            // TODO: Remove other layouts so we can prepare for the next layout

            if device.model == .perKey || device.model == .perKeyGS65 {
                perKeyLayoutSetup()
            }
        }
    }

    func updateDevice(forced: Bool = false) {
        if PrismKeyboard.keysSelected.count > 0 || forced {
            guard let device = PrismDriver.shared.currentDevice, device.model != .threeRegion else {
                return
            }

            device.update()
        }
    }
}

// MARK: Button sidebar delegate

protocol ModesViewControllerDelegate: AnyObject {
    func didClickOnPresetsButton()
}

// MARK: Notification broadcast

extension Notification.Name {
    public static let prismCurrentDeviceChanged = Notification.Name(rawValue: "prismCurrentDeviceChanged")
}
