//
//  PrismAlert.swift
//  PrismUI
//
//  Created by Erik Bautista on 11/24/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

final class PrismAlert: NSObject {

    private let alert: NSAlert
    private var error: Error?
    private var message: String?
    private var info: String?
    private var textField: NSTextField?

    init(error: Error) {
        self.alert = NSAlert(error: error)
        self.error = error
        super.init()
        self.setupAlert()
    }

    init(message: String, info: String) {
        self.alert = NSAlert()
        self.message = message
        self.info = info
        super.init()
        self.setupAlert()
    }

    private func setupAlert() {
        if error != nil {
            alert.alertStyle = .critical
        }

        if let message = message {
            alert.messageText = message
        }

        if let info = info {
            alert.informativeText = info
        }
    }

    static func createSavePresetAlert() -> PrismAlert {
        let prismAlert = PrismAlert(message: "Do you want to save the color effect as a preset?",
                                    info: "Your changes will be lost if you don't save them.")
        let saveButton = prismAlert.alert.addButton(withTitle: "Save")
        saveButton.isEnabled = false
        _ = prismAlert.alert.addButton(withTitle: "Cancel")
        let saveLabel = NSTextField(labelWithString: "Save: ")
        prismAlert.textField = NSTextField(string: "")
        prismAlert.textField?.delegate = prismAlert
        let gridView = NSGridView(frame: NSRect(x: 0, y: 0, width: 200, height: 29))
        gridView.rowAlignment = .firstBaseline
        gridView.addRow(with: [saveLabel, prismAlert.textField!])
        prismAlert.alert.accessoryView = gridView
        prismAlert.alert.layout()
        return prismAlert
    }

    func show() -> String? {
        let retVal = alert.runModal()
        if retVal == .alertFirstButtonReturn, let textField = textField, textField.isEditable {
            return textField.stringValue
        }
        return nil
    }
}

extension PrismAlert: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            if let device = PrismDriver.shared.currentDevice,
               let usedPresetsName = PresetsManager.fetchAllCustomPresets(with: device.model)?
                .children.compactMap({ $0.title }) {
                let textBox = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if let saveButton = alert.buttons.first(where: { button -> Bool in
                    button.title == "Save"
                }) {
                    saveButton.isEnabled = !textBox.isEmpty && !usedPresetsName.contains(textBox)
                }
            }
        }
    }
}
