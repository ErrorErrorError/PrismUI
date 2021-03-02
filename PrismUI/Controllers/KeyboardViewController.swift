//
//  PerKeyViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyboardViewController: BaseViewController {

    var originView: OriginEffectView?
    var saveButton: NSButton?

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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(createSavePresetWindow(_:)),
                                               name: .prismDeviceSavePreset,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDeviceView),
                                               name: .prismDeviceUpdateView,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .prismDeviceUpdateFromPreset, object: nil)
        NotificationCenter.default.removeObserver(self, name: .prismDeviceSavePreset, object: nil)
        NotificationCenter.default.removeObserver(self, name: .prismDeviceUpdateView, object: nil)
    }
}

// MARK: Actions

extension KeyboardViewController {

    @objc func updateDeviceView() {
        guard let device = PrismDriver.shared.currentDevice else { return }
        if device.isKeyboardDevice && device.model != .threeRegion {
            DispatchQueue.main.async {
                self.view.subviews.compactMap({ $0 as? PerKeyColorView}).forEach { $0.updateAnimation() }
            }
        }
    }

    @objc func createSavePresetWindow(_ notification: Notification) {
        guard let device = PrismDriver.shared.currentDevice,
              device.isKeyboardDevice,
              device.model != .threeRegion else {
            Log.error("Could not get current device selected.")
            return
        }

        let prismKeys = PrismKeyboardDevice.keys.compactMap { $0 as? PrismKey }

        let savePresetAlert = PrismAlert.createSavePresetAlert()
        if let presetName = savePresetAlert.show() {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            if let data = try? encoder.encode(prismKeys) {
                DispatchQueue.global(qos: .background).async {
                    do {
                        let presetURL = try PresetsManager.createCustomPresetFile(data: data,
                                                                                  deviceModel: device.model,
                                                                                  name: presetName)
                        NotificationCenter.default.post(name: .prismDeviceSavePresetFile,
                                                        object: (device.identification, presetURL))
                    } catch {
                        DispatchQueue.main.async {
                            NSAlert(error: error).runModal()
                        }
                    }
                }
            }
        }
    }

    @objc func updateKeyboardToPreset(_ notification: Notification) {
        guard let preset = notification.object as? PrismPreset else { return }
        guard let device = PrismDriver.shared.currentDevice, device.isKeyboardDevice else { return }

        if device.model != .threeRegion {
            guard let url = preset.url, let data = try? Data(contentsOf: url) else { return }
            PrismKeyboardDevice.effects.removeAllObjects()
            PrismKeyboardDevice.keysSelected.removeAllObjects()

            // MARK: Deserialize JSON

            do {
                let keys = try JSONDecoder().decode([PrismKey].self, from: data)
                let effectsArray = keys.compactMap { $0.effect }
                let effectsSet = NSSet(array: effectsArray).allObjects.compactMap({ $0 as? PrismEffect })
                PrismKeyboardDevice.effects.addObjects(from: effectsSet)
                for key in keys {
                    if key.effect != nil {
                        for effect in effectsSet where key.effect == effect {
                            key.effect = effect
                        }
                    }

                    keyViewLoop: for keyView in view.subviews.compactMap({ $0 as? PerKeyColorView }) {
                        if let keyObj = keyView.prismKey, keyObj.region == key.region && keyObj.keycode == key.keycode {
                            keyView.selected = false
                            keyObj.mode = key.mode
                            keyObj.effect = key.effect
                            keyObj.main = key.effect?.start ?? key.main
                            keyObj.active = key.active
                            keyObj.duration = key.duration
                            break keyViewLoop
                        }
                    }
                }

                updateDeviceView()

                device.update(forceUpdate: true)
            } catch {
                Log.error("\(error)")
            }
        }
    }
}
