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
        view.addSubview(multiSlider)
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

        modesPopUp.addItem(withTitle: "\(PrismKeyModes.steady)")
        modesPopUp.addItem(withTitle: "\(PrismKeyModes.colorShift)")
        modesPopUp.addItem(withTitle: "\(PrismKeyModes.breathing)")
        modesPopUp.addItem(withTitle: "\(PrismKeyModes.reactive)")
        modesPopUp.addItem(withTitle: "\(PrismKeyModes.disabled)")
        modesPopUp.addItem(withTitle: "Mixed")
        modesPopUp.item(withTitle: "Mixed")?.isHidden = true
        modesPopUp.selectItem(withTitle: "\(PrismKeyModes.steady)")

        perKeySetupContraints()
        updatePending = false
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
    func handlePerKeyPopup(_ sender: NSPopUpButton) {
        Log.debug("sender: \(String(describing: sender.titleOfSelectedItem))")
        switch sender.titleOfSelectedItem {
        case "\(PrismKeyModes.steady)":
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
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

        colorPicker.setColor(newColor: PrismRGB(red: 1.0, green: 0, blue: 0))
        didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
    }

    func handlePerKeyButtonClicked(_ sender: NSButton, update: Bool = true) {
        guard let identifier = sender.identifier else { return }
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

        if shouldShow {
            multiSlider.mode = .colorShift
            speedSlider.minValue = 100
            speedSlider.maxValue = 3000
            speedSlider.intValue = 300
            pulseSlider.intValue = 100
            waveToggle.state = .off
            waveInwardOutwardControl.selectedSegment = 1
            waveDirectionControl.selectedSegment = 0
            onButtonClicked(waveToggle, update: false)
            onSliderChanged(speedSlider, update: false)
            onSliderChanged(pulseSlider, update: false)
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

    func updatePerKeyColors(newColor: PrismRGB, finished: Bool) {
        let selectedItem = modesPopUp.indexOfSelectedItem
        guard selectedItem != -1, let selectedMode = PrismKeyModes(rawValue: UInt32(selectedItem)) else {
            Log.debug("Unknown mode: \(selectedItem)")
            return
        }
        switch selectedMode {
        case PrismKeyModes.steady:
            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                if prismKey.mode != .steady || prismKey.main != newColor {
                    prismKey.mode = .steady
                    prismKey.main = newColor
                    updatePending = true
                }
                colorView.prismKey = prismKey
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
            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                if prismKey.effect != effect {
                    prismKey.mode = selectedMode
                    prismKey.effect = effect
                    prismKey.main = effect.start
                    colorView.prismKey = prismKey
                    updatePending = true
                }
            }
        case PrismKeyModes.reactive:
            ModesViewController.selectorArray.filter { ($0 as? ColorView) != nil }.forEach {
                guard let colorView = $0 as? ColorView else { return }
                colorView.color = newColor.nsColor
            }

            let activeColor = reactActiveColor.color.prismRGB
            let baseColor = reactRestColor.color.prismRGB
            let speedDuration = UInt16(speedSlider.intValue)

            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
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
                    colorView.prismKey = prismKey
                    updatePending = true
                }
            }
        case PrismKeyModes.disabled:
            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                if prismKey.mode != .disabled {
                    prismKey.mode = .disabled
                    colorView.prismKey = prismKey
                    updatePending = true
                }
            }
        }

        removeUnusedEffecs()
        if finished && updatePending {
            updateDevice()
            updatePending = false
        }
    }

    private func getKeyEffect(mode: PrismKeyModes) -> PrismEffect? {
        var identifier: UInt8 = 0
        let usedEffectId: [UInt8] = PrismKeyboard.keys.compactMap { ($0 as? PrismKey)?.effect?.identifier }
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

        let effect = PrismEffect(identifier: identifier, transitions: transitions)
        if mode == .colorShift {
            effect.waveActive = waveToggle.state == .on
            if waveToggle.state == .on {
                effect.origin = PrismPoint(xAxis: 0, yAxis: 0)
                effect.pulse = UInt16(pulseValue.integerValue)
                effect.direction = PrismDirection(rawValue: UInt8(waveDirectionControl.selectedSegment)) ?? .xyAxis
                effect.control = PrismControl(rawValue: UInt8(waveInwardOutwardControl.selectedSegment)) ?? .inward
            }
        }

        for element in PrismKeyboard.effects.compactMap({ $0 as? PrismEffect }) where element == effect {
                return element
        }

        PrismKeyboard.effects.add(effect)
        return effect
    }

    private func removeUnusedEffecs() {
        let effectsNotUsed = PrismKeyboard.effects
            .compactMap { ($0 as? PrismEffect) }
            .filter { !PrismKeyboard.keys.compactMap { ($0 as? PrismKey)?.effect }.contains($0) }
        PrismKeyboard.effects.removeObjects(in: effectsNotUsed)
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
