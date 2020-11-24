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
                                               selector: #selector(createPresetWindow(_:)),
                                               name: .prismDeviceSavePreset,
                                               object: nil)
    }
}

// MARK: Actions

extension KeyboardViewController {
    @objc func createPresetWindow(_ notification: Notification) {
        guard let currentWindow = view.window else {
            Log.error("Could not show view window due to window == nil")
             return
        }

        guard let device = PrismDriver.shared.currentDevice,
              device.isKeyboardDevice,
              device.model != .threeRegion else {
            Log.error("Could not get current device selected.")
            return
        }

        let prismKeys = PrismKeyboardDevice.keys.compactMap { $0 as? PrismKey }

        let savePresetAlert = NSAlert()
        savePresetAlert.messageText = "Do you want to save the color effect as a preset?"
        savePresetAlert.informativeText = "Your changes will be lost if you don't save them."
        saveButton = savePresetAlert.addButton(withTitle: "Save")
        saveButton?.isEnabled = false
        savePresetAlert.addButton(withTitle: "Cancel")
        let saveLabel = NSTextField(labelWithString: "Save: ")
        let saveLabelText = NSTextField(string: "")
        saveLabelText.delegate = self
        let gridView = NSGridView(frame: NSRect(x: 0, y: 0, width: 200, height: 29))
        gridView.rowAlignment = .firstBaseline
        gridView.addRow(with: [saveLabel, saveLabelText])
        savePresetAlert.accessoryView = gridView
        savePresetAlert.layout()
        savePresetAlert.beginSheetModal(for: currentWindow) { response in
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                let presetName = saveLabelText.stringValue
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
                } else {
                    Log.error("Error trying to encode items.")
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

                    keyViewLoop: for keyView in view.subviews.compactMap({ $0 as? KeyColorView }) {
                        if let keyObj = keyView.prismKey, keyObj.region == key.region && keyObj.keycode == key.keycode {
                            keyView.selected = false
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

extension KeyboardViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            if let device = PrismDriver.shared.currentDevice,
               let usedPresetsName = PresetsManager.fetchAllCustomPresets(with: device.model)?
                .children.compactMap({ $0.title }) {
                let textBox = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                saveButton?.isEnabled = !textBox.isEmpty && !usedPresetsName.contains(textBox)
            }
        }
    }
}
