//
//  PerKeyswift
//  PrismUI
//
//  Created by Erik Bautista on 3/3/21.
//  Copyright © 2021 ErrorErrorError. All rights reserved.
//

import Cocoa

class PerKeyControlViewController: BaseViewController {

    var updatePending = false

    private var selectorDragging = false

    private let selectorArray = NSMutableArray()

    // Per Key Views

    let speedLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Speed")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()

    let speedSlider: NSSlider = {
        let slider = NSSlider(value: 3000,
                             minValue: 1000,
                             maxValue: 30000,
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
        let segmented = NSSegmentedControl(labels: ["In", "Out"],
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

    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainView = view as? NSVisualEffectView {
            mainView.material = .windowBackground
        }

        speedSlider.target = self
        speedSlider.action = #selector(onSliderChanged(_:update:))
        waveToggle.target = self
        waveToggle.action = #selector(onButtonClicked(_:update:))
        pulseSlider.target = self
        pulseSlider.action = #selector(onSliderChanged(_:update:))
        originButton.target = self
        originButton.action = #selector(onButtonClicked(_:update:))
        waveDirectionControl.target = self
        waveDirectionControl.action = #selector(onButtonClicked(_:update:))
        waveInwardOutwardControl.target = self
        waveInwardOutwardControl.action = #selector(onButtonClicked(_:update:))

        reactActiveColor.delegate = self
        reactRestColor.delegate = self
        multiSlider.delegate = self

        view.addSubview(speedLabel)
        view.addSubview(speedSlider)
        view.addSubview(speedValue)
        view.addSubview(waveToggle)
        view.addSubview(originButton)
        view.addSubview(waveDirectionControl)
        view.addSubview(waveInwardOutwardControl)
        view.addSubview(pulseLabel)
        view.addSubview(pulseSlider)
        view.addSubview(pulseValue)
        view.addSubview(reactActiveText)
        view.addSubview(reactActiveColor)
        view.addSubview(reactRestText)
        view.addSubview(reactRestColor)
        view.addSubview(multiSlider)

        guard let parentModes = parent as? DeviceControlViewController else { return }
        parentModes.modesPopUp.removeAllItems()
        parentModes.modesPopUp.addItem(withTitle: "\(PrismKeyModes.steady)")
        parentModes.modesPopUp.addItem(withTitle: "\(PrismKeyModes.colorShift)")
        parentModes.modesPopUp.addItem(withTitle: "\(PrismKeyModes.breathing)")
        parentModes.modesPopUp.addItem(withTitle: "\(PrismKeyModes.reactive)")
        parentModes.modesPopUp.addItem(withTitle: "\(PrismKeyModes.disabled)")
        parentModes.modesPopUp.addItem(withTitle: "Mixed")
        parentModes.modesPopUp.item(withTitle: "Mixed")?.isHidden = true
        parentModes.modesPopUp.selectItem(withTitle: "\(PrismKeyModes.steady)")
        parentModes.deviceControlDelegate = self

        PrismKeyboardDevice.origin.xPoint = 0
        PrismKeyboardDevice.origin.yPoint = 0

        perKeySetupConstraints()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeySelectionChanged),
                                               name: .keySelectionChanged,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateEffectFromOrigin(notification:)),
                                               name: .prismUpdateFromNewPoint,
                                               object: nil)
    }

    private func perKeySetupConstraints() {
        view.subviews.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
        }

        // Reactive Constraints
        let heightView: CGFloat = 40

        reactActiveColor.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        reactActiveColor.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        reactActiveColor.widthAnchor.constraint(equalToConstant: heightView - 8).isActive = true
        reactActiveColor.heightAnchor.constraint(equalToConstant: heightView - 8).isActive = true

        reactActiveText.leadingAnchor.constraint(equalTo: reactActiveColor.trailingAnchor, constant: 10).isActive = true
        reactActiveText.centerYAnchor.constraint(equalTo: reactActiveColor.centerYAnchor).isActive = true

        reactRestColor.leadingAnchor.constraint(equalTo: reactActiveText.trailingAnchor, constant: 20).isActive = true
        reactRestColor.topAnchor.constraint(equalTo: reactActiveColor.topAnchor).isActive = true
        reactRestColor.widthAnchor.constraint(equalTo: reactActiveColor.widthAnchor).isActive = true
        reactRestColor.heightAnchor.constraint(equalTo: reactActiveColor.heightAnchor).isActive = true

        reactRestText.leadingAnchor.constraint(equalTo: reactRestColor.trailingAnchor, constant: 10).isActive = true
        reactRestText.centerYAnchor.constraint(equalTo: reactRestColor.centerYAnchor).isActive = true

        // ColorShift / Breathing cconstraints

        multiSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        multiSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        multiSlider.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        multiSlider.heightAnchor.constraint(equalToConstant: heightView).isActive = true

        speedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        speedLabel.topAnchor.constraint(equalTo: multiSlider.bottomAnchor,
                                        constant: 8).isActive = true
        speedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        speedSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        speedSlider.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 4).isActive = true
        speedSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28).isActive = true

        speedValue.leadingAnchor.constraint(equalTo: speedSlider.trailingAnchor, constant: 8).isActive = true
        speedValue.topAnchor.constraint(equalTo: speedSlider.topAnchor).isActive = true
        speedValue.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        waveToggle.topAnchor.constraint(equalTo: speedSlider.bottomAnchor, constant: 12).isActive = true
        waveToggle.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        originButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        originButton.centerYAnchor.constraint(equalTo: waveToggle.centerYAnchor).isActive = true

        waveDirectionControl.topAnchor.constraint(equalTo: waveToggle.bottomAnchor, constant: 12).isActive = true
        waveDirectionControl.leadingAnchor.constraint(equalTo: waveToggle.leadingAnchor).isActive = true

        waveInwardOutwardControl.centerYAnchor.constraint(equalTo: waveDirectionControl.centerYAnchor).isActive = true
        waveInwardOutwardControl.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        pulseLabel.topAnchor.constraint(equalTo: waveDirectionControl.bottomAnchor, constant: 12).isActive = true
        pulseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        pulseSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pulseSlider.topAnchor.constraint(equalTo: pulseLabel.bottomAnchor, constant: 4).isActive = true
        pulseSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28).isActive = true

        pulseValue.leadingAnchor.constraint(equalTo: pulseSlider.trailingAnchor, constant: 8).isActive = true
        pulseValue.topAnchor.constraint(equalTo: pulseSlider.topAnchor).isActive = true
        pulseValue.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

// MARK: Delegate for PrismMultiSliders

extension PerKeyControlViewController: PrismMultiSliderDelegate {

    func added(_ sender: PrismSelector) {
        updateViews(color: sender.color.rgb, finished: true)
    }

    func event(_ sender: PrismSelector, _ event: NSEvent) {
        guard let colorPicker = (parent as? DeviceControlViewController)?.colorPicker else { return }

        switch event.type {
        case .leftMouseDragged:
            selectorDragging = true
            updateViews(color: colorPicker.colorGraphView.color.rgb, finished: false)
        case .leftMouseUp:
            if !selectorDragging {
                if selectorArray.count == 1 {
                    colorPicker.setColor(newColor: sender.color.rgb)
                }
            } else {
                updateViews(color: colorPicker.colorGraphView.color.rgb, finished: false)
                selectorDragging = false
            }
        default:
            Log.debug("Event not valid: \(event.type.rawValue)")
        }
    }

    func didSelect(_ sender: PrismSelector) {
        if let parent = parent as? DeviceControlViewController {
            parent.colorPicker.enabled = true
        }
        selectorArray.add(sender)
    }

    func didDeselect(_ sender: PrismSelector) {
        selectorArray.remove(sender)
        if let parent = parent as? DeviceControlViewController {
            parent.colorPicker.enabled = false
        }
    }
}

// MARK: Delegate selection change for ColorViews

extension PerKeyControlViewController: ColorViewDelegate {
    func didSelect(_ sender: ColorView) {
        if sender == reactActiveColor || sender == reactRestColor,
           let parentMode = parent as? DeviceControlViewController {
            parentMode.colorPicker.enabled = true
            parentMode.colorPicker.setColor(newColor: sender.color.prismHSB)
        }

        selectorArray.add(sender)
    }

    func didDeselect(_ sender: ColorView) {
        selectorArray.remove(sender)

        if !selectorArray.contains(reactActiveColor) &&
            !selectorArray.contains(reactRestColor),
           let parentMode = parent as? DeviceControlViewController {
            parentMode.colorPicker.enabled = false
        }
    }
}

// MARK: Handle actions

extension PerKeyControlViewController {

    @objc func onKeySelectionChanged() {
        guard let parent = (parent as? DeviceControlViewController) else { return }
        let colorPicker = parent.colorPicker
        let selectedKeys = PrismKeyboardDevice.keysSelected.compactMap { ($0 as? PerKeyColorView)?.prismKey }
        if selectedKeys.count == 0 { return }

        let allKeysSame = selectedKeys.allSatisfy {
            $0.effect == selectedKeys.first?.effect &&
            $0.active == selectedKeys.first?.active &&
            $0.main == selectedKeys.first?.main &&
            $0.duration == selectedKeys.first?.duration &&
            $0.mode == selectedKeys.first?.mode
        }

        if allKeysSame {
            let key = selectedKeys.first!
            let modeName = "\(key.mode)"
            if parent.modesPopUp.titleOfSelectedItem != modeName {
                parent.modesPopUp.selectItem(withTitle: modeName)
                modesChanged(mode: modeName, update: false)
            }
            switch modeName {
            case "\(PrismKeyModes.steady)":
                colorPicker.setColor(newColor: key.main)
            case "\(PrismKeyModes.reactive)":
                reactActiveColor.color = key.active.nsColor
                reactRestColor.color = key.main.nsColor
                speedSlider.intValue = Int32(key.duration)
            case "\(PrismKeyModes.colorShift)",
                "\(PrismKeyModes.breathing)":
                guard let effect = key.effect else { return }
                onSliderChanged(speedSlider, update: false)
                multiSlider.mode = modeName == "\(PrismKeyModes.colorShift)" ? .colorShift : .breathing
                multiSlider.setSelectorsFromTransitions(transitions: effect.transitions)
                speedSlider.intValue = Int32(effect.duration)
                onSliderChanged(pulseSlider, update: false)
                if key.mode == .colorShift {
                    waveToggle.state = effect.waveActive ? .on : .off
                    waveDirectionControl.selectedSegment = Int(effect.direction.rawValue)
                    waveInwardOutwardControl.selectedSegment = Int(effect.control.rawValue)
                    pulseSlider.intValue = Int32(effect.pulse)
                    onButtonClicked(waveToggle, update: false)
                    PrismKeyboardDevice.origin.xPoint = effect.origin.xPoint
                    PrismKeyboardDevice.origin.yPoint = effect.origin.yPoint
                    NotificationCenter.default.post(name: .updateOriginView, object: effect.transitions)
                    NotificationCenter.default.post(name: .updateOriginView, object: PrismKeyboardDevice.origin)
                    NotificationCenter.default.post(name: .updateOriginView, object: effect.direction)
                }
            case "\(PrismKeyModes.disabled)":
                showReactiveMode(shouldShow: false)
                showColorShiftMode(shouldShow: false)
                showBreadingMode(shouldShow: false)
                colorPicker.enabled = false
            default:
                return
            }
        } else {
            parent.modesPopUp.item(withTitle: "Mixed")?.isHidden = false
            parent.modesPopUp.selectItem(withTitle: "Mixed")
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            parent.colorPicker.enabled = false
        }
    }

    // Update device from origin

    @objc func updateEffectFromOrigin(notification: Notification) {
        guard let colorPicker = (parent as? DeviceControlViewController)?.colorPicker else { return }
        updateViews(color: colorPicker.colorGraphView.color.rgb, finished: true)
    }

    @objc func onSliderChanged(_ sender: NSSlider, update: Bool = true) {
        guard let identifierr = sender.identifier else { return }
        switch identifierr {
        case .speed:
            speedValue.stringValue = "\(sender.intValue.description.dropLast(waveToggle.isHidden ? 2 : 3))s"
        case .pulse:
            pulseValue.stringValue = "\(sender.intValue.description.dropLast(1))"
        default:
            Log.debug("Slider not implemented \(String(describing: sender.identifier))")
            return
        }

        let event = NSApplication.shared.currentEvent
        if event?.type == NSEvent.EventType.leftMouseUp && update {
            guard let colorPicker = (parent as? DeviceControlViewController)?.colorPicker else { return }
            updateViews(color: colorPicker.colorGraphView.color.rgb, finished: true)
        }
    }

    @objc func onButtonClicked(_ sender: NSButton, update: Bool = true) {
        guard let identifier = sender.identifier else { return }
        switch identifier {
        case .origin:
            NotificationCenter.default.post(name: .prismOriginToggled, object: nil)
            return
        case .xyDirection,
            .inwardOutward:
            break
        case .waveToggle:
            let enabled = sender.state == .on
            originButton.isEnabled = enabled
            waveDirectionControl.isEnabled = enabled
            waveInwardOutwardControl.isEnabled = enabled
            pulseSlider.isEnabled = enabled
            if !enabled {
                NotificationCenter.default.post(name: .prismOriginToggled, object: true)
            }
        default:
            Log.debug("Unkown button pressed \(identifier)")
            return
        }

        if update {
            guard let colorPicker = (parent as? DeviceControlViewController)?.colorPicker else { return }
            updateViews(color: colorPicker.colorGraphView.color.rgb, finished: true)
        }
    }
}

// MARK: device layout settings

extension PerKeyControlViewController {

    func showReactiveMode(shouldShow: Bool = true) {
        selectorArray.filter { ($0 as? ColorView) != nil }.forEach {
            guard let selector = $0 as? ColorView else { return }
            selector.selected = false
        }
        selectorArray.removeAllObjects()
        reactActiveText.isHidden = !shouldShow
        reactActiveColor.isHidden = !shouldShow
        reactRestText.isHidden = !shouldShow
        reactRestColor.isHidden = !shouldShow
        speedLabel.isHidden = !shouldShow
        speedSlider.isHidden = !shouldShow
        speedValue.isHidden = !shouldShow

        if shouldShow {
            speedSlider.minValue = 100
            speedSlider.maxValue = 1000
            speedSlider.intValue = 300
            reactActiveColor.color = PrismRGB(red: 0xff, green: 0x0, blue: 0x0).nsColor
            reactRestColor.color = PrismRGB(red: 0x0, green: 0x0, blue: 0x0).nsColor
            onSliderChanged(speedSlider, update: false)
        }
    }

    func showColorShiftMode(shouldShow: Bool = true) {
        selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
            guard let selector = $0 as? PrismSelector else { return }
            selector.selected = false
        }
        selectorArray.removeAllObjects()
        multiSlider.isHidden = !shouldShow
        speedLabel.isHidden = !shouldShow
        speedSlider.isHidden = !shouldShow
        speedValue.isHidden = !shouldShow
        waveToggle.isHidden = !shouldShow
        originButton.isHidden = !shouldShow
        waveDirectionControl.isHidden = !shouldShow
        waveInwardOutwardControl.isHidden = !shouldShow
        pulseLabel.isHidden = !shouldShow
        pulseSlider.isHidden = !shouldShow
        pulseValue.isHidden = !shouldShow
        NotificationCenter.default.post(name: .prismOriginToggled, object: true)

        if shouldShow {
            multiSlider.mode = .colorShift
            speedSlider.minValue = 1000
            speedSlider.maxValue = 30000
            speedSlider.intValue = 3000
            pulseSlider.intValue = 100
            waveToggle.state = .off
            waveInwardOutwardControl.selectedSegment = 0
            waveDirectionControl.selectedSegment = 0
            PrismKeyboardDevice.origin.xPoint = 0
            PrismKeyboardDevice.origin.yPoint = 0
            onButtonClicked(waveToggle, update: false)
            onSliderChanged(speedSlider, update: false)
            onSliderChanged(pulseSlider, update: false)
            NotificationCenter.default.post(name: .updateOriginView, object: PrismKeyboardDevice.origin)
        }
    }

    func showBreadingMode(shouldShow: Bool = true) {
        selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
            guard let selector = $0 as? PrismSelector else { return }
            selector.selected = false
        }
        selectorArray.removeAllObjects()
        multiSlider.isHidden = !shouldShow
        speedLabel.isHidden = !shouldShow
        speedSlider.isHidden = !shouldShow
        speedValue.isHidden = !shouldShow

        if shouldShow {
            multiSlider.mode = .breathing
            speedSlider.minValue = 2000
            speedSlider.maxValue = 30000
            speedSlider.intValue = 4000
            onSliderChanged(speedSlider, update: false)
        }
    }
}

extension PerKeyControlViewController: PrismDeviceControlDelegate {
    func modesChanged(mode: String, update: Bool) {
        Log.debug("New effect set: \(mode)")
        guard let colorPicker = (parent as? DeviceControlViewController)?.colorPicker else { return }

        colorPicker.enabled = false
        (parent as? DeviceControlViewController)?.modesPopUp.item(withTitle: "Mixed")?.isHidden = true
        switch mode {
        case "\(PrismKeyModes.steady)":
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            colorPicker.enabled = true
            colorPicker.setColor(newColor: PrismRGB(red: 1.0, green: 0, blue: 0))
        case "\(PrismKeyModes.reactive)":
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showReactiveMode()
        case "\(PrismKeyModes.colorShift)":
            showReactiveMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showColorShiftMode()
        case "\(PrismKeyModes.breathing)":
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode()
        case "\(PrismKeyModes.disabled)":
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
        default:
            Log.error("Effect Unavalilable for perKey")
            return
        }

        if update {
            updateViews(color: colorPicker.colorGraphView.color.rgb, finished: true)
        }

    }

    func updateViews(color: PrismRGB, finished: Bool) {
        guard let device = PrismDriver.shared.currentDevice, device.model != .unknown else {
            return
        }
        guard let effectIndex = (parent as? DeviceControlViewController)?.modesPopUp.indexOfSelectedItem else {
            Log.error("Parent class is not an instance of \(DeviceControlViewController.className())")
            return
        }
        let selectedItem = effectIndex
        guard selectedItem != -1, let selectedMode = PrismKeyModes(rawValue: UInt32(selectedItem)) else {
            Log.debug("Unknown mode: \(selectedItem)")
            return
        }
        switch selectedMode {
        case PrismKeyModes.steady:
            PrismKeyboardDevice.keysSelected.filter { ($0 as? PerKeyColorView) != nil }.forEach {
                guard let colorView = $0 as? PerKeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                if prismKey.mode != .steady || prismKey.main != color {
                    prismKey.mode = .steady
                    prismKey.main = color
                    updatePending = true
                }
            }
        case PrismKeyModes.colorShift,
             PrismKeyModes.breathing:
            selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
                guard let selector = $0 as? PrismSelector else { return }
                selector.color = color.hsb
            }

            // Create effect once it's finished updating color
            guard let effect = getKeyEffect(mode: selectedMode) else {
                Log.error("Cannot create effect package due to error in transitions.")
                return
            }

            NotificationCenter.default.post(name: .updateOriginView, object: effect.transitions)
            NotificationCenter.default.post(name: .updateOriginView, object: effect.direction)

            let speedDuration = UInt16(speedSlider.intValue)
            PrismKeyboardDevice.keysSelected.filter { ($0 as? PerKeyColorView) != nil }.forEach {
                guard let colorView = $0 as? PerKeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                if prismKey.effect !== effect ||
                    prismKey.mode != selectedMode ||
                    prismKey.duration != speedDuration {
                    prismKey.mode = selectedMode
                    prismKey.effect = effect
                    prismKey.main = effect.start
                    prismKey.duration = 0x012c
                    updatePending = true
                }
            }
        case PrismKeyModes.reactive:
            selectorArray.filter { ($0 as? ColorView) != nil }.forEach {
                guard let colorView = $0 as? ColorView else { return }
                colorView.color = color.nsColor
            }

            let activeColor = reactActiveColor.color.prismRGB
            let baseColor = reactRestColor.color.prismRGB
            let speedDuration = UInt16(speedSlider.intValue)

            PrismKeyboardDevice.keysSelected.filter { ($0 as? PerKeyColorView) != nil }.forEach {
                guard let colorView = $0 as? PerKeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                if prismKey.mode != .reactive ||
                    prismKey.active != activeColor ||
                    prismKey.main != baseColor ||
                    prismKey.duration != speedDuration {
                    prismKey.mode = .reactive
                    prismKey.active = activeColor
                    prismKey.main = baseColor
                    prismKey.duration = speedDuration
                    updatePending = true
                }
            }
        case PrismKeyModes.disabled:
            PrismKeyboardDevice.keysSelected.filter { ($0 as? PerKeyColorView) != nil }.forEach {
                guard let colorView = $0 as? PerKeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                if prismKey.mode != .disabled {
                    prismKey.mode = .disabled
                    updatePending = true
                }
            }
        }

        removeUnusedEffecs()

        if updatePending {
            NotificationCenter.default.post(name: .prismDeviceUpdateView, object: nil)
        }

        if finished && updatePending {
            updatePerKeyDevice()
            updatePending = false
        }

    }
}

// MARK: Helper methods for PerKey

extension PerKeyControlViewController {

    private func getKeyEffect(mode: PrismKeyModes) -> PrismEffect? {
        var identifier: UInt8 = 0
        let usedEffectId: [UInt8] = PrismKeyboardDevice.keys.compactMap { ($0 as? PrismKey)?.effect?.identifier }
        for unusedId in 1...0xff {
            let containsId = usedEffectId.contains(UInt8(unusedId))
            if !containsId {
                identifier = UInt8(unusedId)
                break
            }
        }

        var transitions: [PrismTransition]
        if mode == .colorShift {
            transitions = multiSlider.colorShiftTransitions()
        } else {
            transitions = multiSlider.breathingTransitions()
        }

        guard transitions.count > 0 else {
            return nil
        }

        let waveActive = waveToggle.state == .on
        let origin = PrismKeyboardDevice.origin.copy() as? PrismPoint ?? PrismPoint()
        let pulse = UInt16(pulseSlider.intValue)
        let direction = PrismDirection(rawValue: UInt8(waveDirectionControl.selectedSegment)) ?? .xyAxis
        let control = PrismControl(rawValue: UInt8(waveInwardOutwardControl.selectedSegment)) ?? .inward
        let transitionDuration = UInt16(speedSlider.intValue)

        // See if it can find an effect with the same settings, if not create a new effect

       var effect = PrismKeyboardDevice.effects.compactMap({ $0 as? PrismEffect }).first(where: {
            $0.start == transitions[0].color &&
                $0.waveActive == waveActive &&
                $0.direction == direction &&
                $0.control == control &&
                $0.origin == origin &&
                $0.pulse == pulse &&
                $0.transitions == transitions &&
                $0.duration == transitionDuration
        })

        if effect == nil {
            effect = PrismEffect(identifier: identifier, transitions: transitions)
            guard let effect = effect else { return nil }
            effect.duration = transitionDuration
            if mode == .colorShift {
                effect.waveActive = waveToggle.state == .on
                if effect.waveActive {
                    effect.origin = PrismKeyboardDevice.origin.copy() as? PrismPoint ?? PrismPoint()
                    effect.pulse = UInt16(pulseSlider.intValue)
                    effect.direction = PrismDirection(rawValue: UInt8(waveDirectionControl.selectedSegment)) ?? .xyAxis
                    effect.control = PrismControl(rawValue: UInt8(waveInwardOutwardControl.selectedSegment)) ?? .inward
                }
            }
            PrismKeyboardDevice.effects.add(effect)
        }

        return effect
    }

    private func removeUnusedEffecs() {
        let effectsNotUsed = PrismKeyboardDevice.effects
            .compactMap { ($0 as? PrismEffect) }
            .filter { !PrismKeyboardDevice.keys.compactMap { ($0 as? PrismKey)?.effect }.contains($0) }
        PrismKeyboardDevice.effects.removeObjects(in: effectsNotUsed)
    }

    private func updatePerKeyDevice(forced: Bool = false) {
        if PrismKeyboardDevice.keysSelected.count > 0 || forced {
            guard let device = PrismDriver.shared.currentDevice as? PrismKeyboardDevice,
                  device.isKeyboardDevice,
                  device.model != .threeRegion else { return }

            device.update()
        }
    }
}

// MARK: Identifiers

extension NSUserInterfaceItemIdentifier {
    static let pulse = NSUserInterfaceItemIdentifier(rawValue: "pulse-slider")
    static let waveToggle = NSUserInterfaceItemIdentifier(rawValue: "wave")
    static let origin = NSUserInterfaceItemIdentifier(rawValue: "origin")
    static let xyDirection = NSUserInterfaceItemIdentifier(rawValue: "xy-direction")
    static let inwardOutward = NSUserInterfaceItemIdentifier(rawValue: "inward-outward")
}

// MARK: Notifications

extension Notification.Name {
    public static let prismOriginToggled = Notification.Name(rawValue: "prismOriginToggled")
    public static let updateOriginView: Notification.Name = .init("updateOriginView")
    public static let prismDeviceUpdateView: Notification.Name = .init("updatePrismDeviceView")
}
