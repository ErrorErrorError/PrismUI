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

    let presetsButton: NSButton = {
        let image = NSImage(named: "NSSidebarTemplate")!
        let button = NSButton(image: image,
                              target: nil,
                              action: #selector(onButtonClicked(_:update:)))
        button.bezelStyle = .rounded
        button.identifier = .presets
        return button
    }()

    let modesLabel: NSTextField = {
        let label = NSTextField(labelWithString: "EFFECT")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let modesPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.action = #selector(didPopupChanged(_:))
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
                             maxValue: 2000,
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

    private var selectorDragging = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainView = view as? NSVisualEffectView {
            mainView.material = .windowBackground
            if let colorPickerView = colorPicker.view as? NSVisualEffectView {
                colorPickerView.material = mainView.material
            }
        }

        guard let device = PrismDriver.shared.currentDevice else { return }
        if device.isKeyboardDevice {
            if device.model != .threeRegion {
                perKeySetup()
            } else {
                // TODO: Setup three region views
            }
        }
    }
}

// MARK: Actions

extension ModesViewController {

    @objc func onSliderChanged(_ sender: NSSlider, update: Bool = true) {
        guard let identifierr = sender.identifier else { return }
        switch identifierr {
        case .speed:
            speedValue.stringValue = "\(sender.intValue.description.dropLast(2))s"
            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let prismKey = ($0 as? KeyColorView)?.prismKey else { return }
                prismKey.duration = UInt16(sender.intValue)
            }
        case .pulse:
            pulseValue.stringValue = "\(sender.intValue.description.dropLast(1))"
        default:
            Log.debug("Slider not implemented \(String(describing: sender.identifier))")
            return
        }

        let event = NSApplication.shared.currentEvent
        if event?.type == NSEvent.EventType.leftMouseUp && update {
            didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
        }
    }

    @objc func onButtonClicked(_ sender: NSButton, update: Bool = true) {
        guard let identifier = sender.identifier else { return }
        Log.debug("Button pressed \(identifier)")
        switch identifier {
        case .presets:
            delegate?.didClickOnPresetsButton()
            return
        case .origin,
             .xyDirection,
             .inwardOutward:
            break
        case .waveToggle:
            let enabled = sender.state == .on
            originButton.isEnabled = enabled
            waveDirectionControl.isEnabled = enabled
            waveInwardOutwardControl.isEnabled = enabled
            pulseSlider.isEnabled = enabled
        default:
            Log.debug("Unkown button pressed \(identifier)")
            return
        }

        didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: update)
    }

    @objc func didPopupChanged(_ sender: NSPopUpButton) {
        Log.debug("sender: \(String(describing: sender.titleOfSelectedItem))")
        switch sender.titleOfSelectedItem {
        case PrismKeyModes.steady.rawValue:
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
        case PrismKeyModes.reactive.rawValue:
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showReactiveMode()
        case PrismKeyModes.colorShift.rawValue:
            showReactiveMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showColorShiftMode()
        case PrismKeyModes.breathing.rawValue:
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode()
        case PrismKeyModes.disabled.rawValue:
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
        default:
            Log.error("Mode Unavalilable")
            return
        }

        colorPicker.setColor(newColor: PrismRGB(red: 1.0, green: 0, blue: 0))
        didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
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

// MARK: Update device

extension ModesViewController {

    func updateDevice(forced: Bool = false) {
        if PrismKeyboard.keysSelected.count > 0 || forced {
            guard let device = PrismDriver.shared.currentDevice, device.model != .threeRegion else {
                return
            }

            device.update()
        }
    }
}

// MARK: MultiSlider Selector delegate

extension ModesViewController: PrismMultiSliderDelegate {

    func added(_ sender: PrismSelector) {
        didColorChange(newColor: sender.color.rgb, finishedChanging: true)
    }

    func event(_ sender: PrismSelector, _ event: NSEvent) {
        switch event.type {
        case .leftMouseDragged:
            selectorDragging = true
            didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: false)
        case .leftMouseUp:
            if !selectorDragging {
                if ModesViewController.selectorArray.count == 1 {
                    colorPicker.setColor(newColor: sender.color.rgb)
                }
            } else {
                didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
                selectorDragging = false
            }
        default:
            Log.debug("Event not valid: \(event.type.rawValue)")
        }
    }

    func didSelect(_ sender: PrismSelector) {
        ModesViewController.selectorArray.add(sender)
    }

    func didDeselect(_ sender: PrismSelector) {
        ModesViewController.selectorArray.remove(sender)
    }
}

// MARK: Reactive delegate

extension ModesViewController: ColorViewDelegate {
    func didSelect(_ sender: ColorView) {
        ModesViewController.selectorArray.add(sender)
    }

    func didDeselect(_ sender: ColorView) {
        ModesViewController.selectorArray.remove(sender)
    }
}

// MARK: Button sidebar delegate

protocol ModesViewControllerDelegate: AnyObject {
    func didClickOnPresetsButton()
}

// MARK: Identifiers

private extension NSUserInterfaceItemIdentifier {
    static let speed = NSUserInterfaceItemIdentifier(rawValue: "speed-slider")
    static let pulse = NSUserInterfaceItemIdentifier(rawValue: "pulse-slider")
    static let waveToggle = NSUserInterfaceItemIdentifier(rawValue: "wave")
    static let origin = NSUserInterfaceItemIdentifier(rawValue: "origin")
    static let xyDirection = NSUserInterfaceItemIdentifier(rawValue: "xy-direction")
    static let inwardOutward = NSUserInterfaceItemIdentifier(rawValue: "inward-outward")
    static let presets = NSUserInterfaceItemIdentifier(rawValue: "presets")
}
