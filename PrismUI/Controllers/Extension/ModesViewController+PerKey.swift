//
//  ModesViewController+Extension.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/3/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

// Per Key Setup view

extension ModesViewController {

    func perKeyLayoutSetup() {
        speedSlider.target = self
        waveToggle.target = self
        pulseSlider.target = self
        originButton.target = self
        waveDirectionControl.target = self
        waveInwardOutwardControl.target = self
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

        modesPopUp.removeAllItems()
        modesPopUp.addItem(withTitle: "\(PrismKeyModes.steady)")
        modesPopUp.addItem(withTitle: "\(PrismKeyModes.colorShift)")
        modesPopUp.addItem(withTitle: "\(PrismKeyModes.breathing)")
        modesPopUp.addItem(withTitle: "\(PrismKeyModes.reactive)")
        modesPopUp.addItem(withTitle: "\(PrismKeyModes.disabled)")
        modesPopUp.addItem(withTitle: "Mixed")
        modesPopUp.item(withTitle: "Mixed")?.isHidden = true
        modesPopUp.selectItem(withTitle: "\(PrismKeyModes.steady)")

        PrismKeyboardDevice.origin.xPoint = 0
        PrismKeyboardDevice.origin.yPoint = 0

        perKeySetupContraints()
        updatePending = false

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeySelectionChanged),
                                               name: .keySelectionChanged,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateEffectFromOrigin(notification:)),
                                               name: .prismUpdateFromNewPoint,
                                               object: nil)
    }

    private func perKeySetupContraints() {
        view.subviews.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
        }

        // Reactive Constraints
        let heightView: CGFloat = 40

        reactActiveColor.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        reactActiveColor.topAnchor.constraint(equalTo: colorPicker.view.bottomAnchor).isActive = true
        reactActiveColor.widthAnchor.constraint(equalToConstant: heightView - 8).isActive = true
        reactActiveColor.heightAnchor.constraint(equalToConstant: heightView - 8).isActive = true

        reactActiveText.leadingAnchor.constraint(equalTo: reactActiveColor.trailingAnchor, constant: 10).isActive = true
        reactActiveText.centerYAnchor.constraint(equalTo: reactActiveColor.centerYAnchor).isActive = true

        reactRestColor.leadingAnchor.constraint(equalTo: reactActiveText.trailingAnchor, constant: 20).isActive = true
        reactRestColor.topAnchor.constraint(equalTo: reactActiveColor.topAnchor).isActive = true
        reactRestColor.widthAnchor.constraint(equalTo: reactActiveColor.widthAnchor).isActive = true
        reactRestColor.heightAnchor.constraint(equalTo: reactActiveColor.heightAnchor).isActive = true

        reactRestText.leadingAnchor.constraint(equalTo: reactRestColor.trailingAnchor, constant: 10).isActive = true
        reactRestText.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
        reactRestText.centerYAnchor.constraint(equalTo: reactRestColor.centerYAnchor).isActive = true

        // ColorShift / Breathing cconstraints

        multiSlider.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        multiSlider.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
        multiSlider.topAnchor.constraint(equalTo: colorPicker.view.bottomAnchor).isActive = true
        multiSlider.heightAnchor.constraint(equalToConstant: heightView).isActive = true

        speedLabel.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        speedLabel.topAnchor.constraint(equalTo: colorPicker.view.bottomAnchor,
                                        constant: heightView + 8).isActive = true
        speedLabel.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true

        speedSlider.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        speedSlider.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 4).isActive = true
        speedSlider.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor, constant: -28).isActive = true

        speedValue.leadingAnchor.constraint(equalTo: speedSlider.trailingAnchor, constant: 8).isActive = true
        speedValue.topAnchor.constraint(equalTo: speedSlider.topAnchor).isActive = true
        speedValue.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true

        waveToggle.topAnchor.constraint(equalTo: speedSlider.bottomAnchor, constant: 12).isActive = true
        waveToggle.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true

        originButton.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
        originButton.centerYAnchor.constraint(equalTo: waveToggle.centerYAnchor).isActive = true

        waveDirectionControl.topAnchor.constraint(equalTo: waveToggle.bottomAnchor, constant: 12).isActive = true
        waveDirectionControl.leadingAnchor.constraint(equalTo: waveToggle.leadingAnchor).isActive = true

        waveInwardOutwardControl.centerYAnchor.constraint(equalTo: waveDirectionControl.centerYAnchor).isActive = true
        waveInwardOutwardControl.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true

        pulseLabel.topAnchor.constraint(equalTo: waveDirectionControl.bottomAnchor, constant: 12).isActive = true
        pulseLabel.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true

        pulseSlider.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        pulseSlider.topAnchor.constraint(equalTo: pulseLabel.bottomAnchor, constant: 4).isActive = true
        pulseSlider.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor, constant: -28).isActive = true

        pulseValue.leadingAnchor.constraint(equalTo: pulseSlider.trailingAnchor, constant: 8).isActive = true
        pulseValue.topAnchor.constraint(equalTo: pulseSlider.topAnchor).isActive = true
        pulseValue.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
    }
}

// MARK: Action PerKey

extension ModesViewController {
    func handlePerKeyPopup(_ sender: NSPopUpButton, update: Bool = true) {
        Log.debug("sender: \(String(describing: sender.titleOfSelectedItem))")
        switch sender.titleOfSelectedItem {
        case "\(PrismKeyModes.steady)":
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            modesPopUp.item(withTitle: "Mixed")?.isHidden = true
            colorPicker.enabled = true
        case "\(PrismKeyModes.reactive)":
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showReactiveMode()
            modesPopUp.item(withTitle: "Mixed")?.isHidden = true
            colorPicker.enabled = true
        case "\(PrismKeyModes.colorShift)":
            showReactiveMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showColorShiftMode()
            modesPopUp.item(withTitle: "Mixed")?.isHidden = true
            colorPicker.enabled = true
        case "\(PrismKeyModes.breathing)":
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode()
            modesPopUp.item(withTitle: "Mixed")?.isHidden = true
            colorPicker.enabled = true
        case "\(PrismKeyModes.disabled)":
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            modesPopUp.item(withTitle: "Mixed")?.isHidden = true
            colorPicker.enabled = true
        default:
            Log.error("Effect Unavalilable for perKey")
            return
        }

        colorPicker.setColor(newColor: PrismRGB(red: 1.0, green: 0, blue: 0))
        if update {
            didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
        }
    }

    func handlePerKeyButtonClicked(_ sender: NSButton, update: Bool = true) {
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
            didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
        }
    }

    func handlePerKeySliderChanged(_ sender: NSSlider, update: Bool = true) {
        guard let identifierr = sender.identifier else { return }
        switch identifierr {
        case .speed:
            speedValue.stringValue = "\(sender.intValue.description.dropLast(2))s"
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

    @objc func onKeySelectionChanged() {
        let selectedKeys = PrismKeyboardDevice.keysSelected.compactMap { ($0 as? KeyColorView)?.prismKey }
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
            if modesPopUp.titleOfSelectedItem != modeName {
                modesPopUp.selectItem(withTitle: modeName)
                handlePerKeyPopup(modesPopUp, update: false)
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
                handlePerKeySliderChanged(speedSlider, update: false)
                multiSlider.mode = modeName == "\(PrismKeyModes.colorShift)" ? .colorShift : .breathing
                multiSlider.setSelectorsFromTransitions(transitions: effect.transitions)
                speedSlider.intValue = Int32(key.duration)
                handlePerKeySliderChanged(pulseSlider, update: false)
                if key.mode == .colorShift {
                    waveToggle.state = effect.waveActive ? .on : .off
                    waveDirectionControl.selectedSegment = Int(effect.direction.rawValue)
                    waveInwardOutwardControl.selectedSegment = Int(effect.control.rawValue)
                    pulseSlider.intValue = Int32(effect.pulse)
                    handlePerKeyButtonClicked(waveToggle, update: false)
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
            modesPopUp.item(withTitle: "Mixed")?.isHidden = false
            modesPopUp.selectItem(withTitle: "Mixed")
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            colorPicker.enabled = false
        }
    }

    // Update device from origin

    @objc func updateEffectFromOrigin(notification: Notification) {
        didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
    }
}

// MARK: device settings

extension ModesViewController {

    // MARK: PerKey Modes state

    func showReactiveMode(shouldShow: Bool = true) {
        ModesViewController.selectorArray.filter { ($0 as? ColorView) != nil }.forEach {
            guard let selector = $0 as? ColorView else { return }
            selector.selected = false
        }
        ModesViewController.selectorArray.removeAllObjects()
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
        ModesViewController.selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
            guard let selector = $0 as? PrismSelector else { return }
            selector.selected = false
        }
        ModesViewController.selectorArray.removeAllObjects()
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
            speedSlider.minValue = 100
            speedSlider.maxValue = 3000
            speedSlider.intValue = 300
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
        ModesViewController.selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
            guard let selector = $0 as? PrismSelector else { return }
            selector.selected = false
        }
        ModesViewController.selectorArray.removeAllObjects()
        multiSlider.isHidden = !shouldShow
        speedLabel.isHidden = !shouldShow
        speedSlider.isHidden = !shouldShow
        speedValue.isHidden = !shouldShow

        if shouldShow {
            multiSlider.mode = .breathing
            speedSlider.minValue = 200
            speedSlider.maxValue = 3000
            speedSlider.intValue = 400
            onSliderChanged(speedSlider, update: false)
        }
    }

    func updatePerKeyViews(newColor: PrismRGB, finished: Bool) {
        let selectedItem = modesPopUp.indexOfSelectedItem
        guard selectedItem != -1, let selectedMode = PrismKeyModes(rawValue: UInt32(selectedItem)) else {
            Log.debug("Unknown mode: \(selectedItem)")
            return
        }
        switch selectedMode {
        case PrismKeyModes.steady:
            PrismKeyboardDevice.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                if prismKey.mode != .steady || prismKey.main != newColor {
                    prismKey.mode = .steady
                    prismKey.main = newColor
                    updatePending = true
                }
            }
        case PrismKeyModes.colorShift,
             PrismKeyModes.breathing:
            ModesViewController.selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
                guard let selector = $0 as? PrismSelector else { return }
                selector.color = newColor.hsb
            }

            // Create effect once it's finished updating color
            guard let effect = getKeyEffect(mode: selectedMode) else {
                Log.error("Cannot create effect package due to error in transitions.")
                return
            }

            NotificationCenter.default.post(name: .updateOriginView, object: effect.transitions)
            NotificationCenter.default.post(name: .updateOriginView, object: effect.direction)

            let speedDuration = UInt16(speedSlider.intValue)
            PrismKeyboardDevice.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                if prismKey.effect != effect ||
                    prismKey.mode != selectedMode ||
                    prismKey.duration != speedDuration {
                    prismKey.mode = selectedMode
                    prismKey.effect = effect
                    prismKey.main = effect.start
                    prismKey.duration = speedDuration
                    updatePending = true
                }
            }
        case PrismKeyModes.reactive:
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
            ModesViewController.selectorArray.filter { ($0 as? ColorView) != nil }.forEach {
                guard let colorView = $0 as? ColorView else { return }
                colorView.color = newColor.nsColor
            }
//            CATransaction.commit()

            let activeColor = reactActiveColor.color.prismRGB
            let baseColor = reactRestColor.color.prismRGB
            let speedDuration = UInt16(speedSlider.intValue)

            PrismKeyboardDevice.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
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
            PrismKeyboardDevice.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
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
            updateDevice()
            updatePending = false
        }
    }

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
            transitions = multiSlider.colorShiftTransitions(speed: CGFloat(speedSlider.floatValue))
        } else {
            transitions = multiSlider.breathingTransitions(speed: CGFloat(speedSlider.floatValue))
        }

        guard transitions.count > 0 else {
            return nil
        }

        var effect = PrismEffect(identifier: identifier, transitions: transitions)
        if mode == .colorShift {
            effect.waveActive = waveToggle.state == .on
            if effect.waveActive {
                effect.origin = PrismKeyboardDevice.origin.copy() as? PrismPoint ?? PrismPoint()
                effect.pulse = UInt16(pulseSlider.intValue)
                effect.direction = PrismDirection(rawValue: UInt8(waveDirectionControl.selectedSegment)) ?? .xyAxis
                effect.control = PrismControl(rawValue: UInt8(waveInwardOutwardControl.selectedSegment)) ?? .inward
            }
        }

        effect = PrismKeyboardDevice.effects.compactMap({ $0 as? PrismEffect }).first(where: {$0 == effect}) ?? effect
        PrismKeyboardDevice.effects.add(effect)
        return effect

    }

    private func removeUnusedEffecs() {
        let effectsNotUsed = PrismKeyboardDevice.effects
            .compactMap { ($0 as? PrismEffect) }
            .filter { !PrismKeyboardDevice.keys.compactMap { ($0 as? PrismKey)?.effect }.contains($0) }
        PrismKeyboardDevice.effects.removeObjects(in: effectsNotUsed)
    }

    func removePerKeySettingsLayout() {
        let perKeyViews = [
            multiSlider,
            speedLabel,
            speedSlider,
            speedValue,
            waveToggle,
            originButton,
            waveDirectionControl,
            waveInwardOutwardControl,
            pulseLabel,
            pulseSlider,
            pulseValue,
            reactActiveText,
            reactActiveColor,
            reactRestText,
            reactRestColor
        ]

        perKeyViews.forEach { $0.animator().removeFromSuperview() }
        modesPopUp.removeAllItems()
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
