//
//  ModesViewController+Extension.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/3/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

// Per Key Setup view

extension ModesViewController {

    func perKeySetup() {
        presetsButton.target = self
        modesPopUp.target = self
        speedSlider.target = self
        waveToggle.target = self
        pulseSlider.target = self
        originButton.target = self
        waveDirectionControl.target = self
        waveInwardOutwardControl.target = self
        colorPicker.delegate = self
        reactActiveColor.delegate = self
        reactRestColor.delegate = self
        multiSlider.delegate = self
        view.addSubview(presetsButton)
        view.addSubview(modesLabel)
        view.addSubview(modesPopUp)
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

        addChild(colorPicker)
        view.addSubview(colorPicker.view)

        modesPopUp.addItem(withTitle: PrismKeyModes.steady.rawValue)
        modesPopUp.addItem(withTitle: PrismKeyModes.colorShift.rawValue)
        modesPopUp.addItem(withTitle: PrismKeyModes.breathing.rawValue)
        modesPopUp.addItem(withTitle: PrismKeyModes.reactive.rawValue)
        modesPopUp.addItem(withTitle: PrismKeyModes.disabled.rawValue)
        modesPopUp.addItem(withTitle: "Mixed")
        modesPopUp.item(withTitle: "Mixed")?.isHidden = true

        perKeySetupContraints()
    }

    private func perKeySetupContraints() {
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
            speedSlider.maxValue = 2000
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
            speedSlider.maxValue = 2000
            speedSlider.intValue = 400
            onSliderChanged(speedSlider, update: false)
        }
    }

    func updatePerKeyColors(newColor: PrismRGB, finished: Bool) {
        guard let selectedItem = modesPopUp.titleOfSelectedItem else { return }
        guard let selectedMode = PrismKeyModes(rawValue: selectedItem) else {
            Log.debug("Unknown mode: \(selectedItem)")
            return
        }
        switch selectedMode {
        case PrismKeyModes.steady:
            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                prismKey.mode = .steady
                prismKey.main = newColor
                colorView.prismKey = prismKey
                updatePending = true
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

            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                prismKey.mode = .reactive
                prismKey.active = reactActiveColor.color.prismRGB
                prismKey.main = reactRestColor.color.prismRGB
                colorView.prismKey = prismKey
                updatePending = true
            }
        case PrismKeyModes.disabled:
            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                prismKey.mode = .disabled
                colorView.prismKey = prismKey
                updatePending = true
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
}
