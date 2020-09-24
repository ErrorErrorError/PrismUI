//
//  PerKeyViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyboardViewController: BaseViewController {

    override func loadView() {
        view = DragSelectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        (self.view as? NSVisualEffectView)?.material = .contentBackground
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard let prismDevice = PrismDriver.shared.currentDevice,
            prismDevice.isKeyboardDevice else { return }
        if prismDevice.model != .threeRegion {
            setupPerKeyLayout(model: prismDevice.model)
        } else {
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateKeyboardToPreset(_:)),
                                               name: .prismDeviceUpdateFromPreset,
                                               object: nil)
    }

    @objc func updateKeyboardToPreset(_ notification: Notification) {
        guard let preset = notification.object as? PrismPreset else { return }
        guard let device = PrismDriver.shared.currentDevice, device.isKeyboardDevice else { return }

        if device.model != .threeRegion {
            guard let url = preset.url, let data = try? Data(contentsOf: url) else { return }
            PrismKeyboard.effects.removeAllObjects()
            PrismKeyboard.keysSelected.removeAllObjects()

            // MARK: Deserialize JSON

            do {
                let keys = try JSONDecoder().decode([PrismKey].self, from: data)
                let effectsArray = keys.compactMap { $0.effect }
                let effectsSet = NSSet(array: effectsArray).allObjects.compactMap({ $0 as? PrismEffect })
                PrismKeyboard.effects.addObjects(from: effectsSet)
                for key in keys {
                    if key.effect != nil {
                        for effect in effectsSet where key.effect == effect {
                            key.effect = effect
                        }
                    }

                    keyViewLoop: for keyView in view.subviews.compactMap({ $0 as? KeyColorView }) {
                        if let keyObj = keyView.prismKey, keyObj.region == key.region && keyObj.keycode == key.keycode {
                            keyObj.mode = key.mode
                            keyObj.effect = key.effect
                            keyObj.main = key.main
                            keyObj.active = key.active
                            keyObj.duration = key.duration
                            keyView.updateAnimation()
                            break keyViewLoop
                        }
                    }
                }

                device.update(forceUpdate: true)
            } catch {
                Log.error("\(error)")
            }
        }
    }
}

extension KeyboardViewController: ColorViewDelegate {
    func didSelect(_ sender: ColorView) {
        if !PrismKeyboard.keysSelected.contains(sender) {
            PrismKeyboard.keysSelected.add(sender)
        }
    }

    func didDeselect(_ sender: ColorView) {
        if PrismKeyboard.keysSelected.contains(sender) {
            PrismKeyboard.keysSelected.remove(sender)
        }
    }
}
