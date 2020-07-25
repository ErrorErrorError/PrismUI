//
//  PrismColorPicker.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/21/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

public class PrismColorPicker: BaseViewController {

    var colorGraphView: PrismColorGraphView!
    var colorSliderView: PrismColorSliderView!
    weak var delegate: PrismColorPickerDelegate?
    private var oldStringBeforeEditing: String = ""

    let colorDropperIcon: NSImageView = {
        let imageView = NSImageView()
        let image = #imageLiteral(resourceName: "ColorDropper")
        imageView.image = image
        return imageView
    }()

    let hashtagLabel: NSTextField = {
        let label = NSTextField()
        label.stringValue = "#"
        label.setAsLabel()
        return label
    }()

    let hexColorField: NSTextField = {
       let label = NSTextField()
        label.placeholderString = "000000"
        label.setupTextField()
        label.action = #selector(onTextEntered(_:))
        return label
    }()

    let rLabel: NSTextField = {
        let label = NSTextField()
        label.stringValue = "R"
        label.setAsLabel()
        return label
    }()

    let rColorField: NSTextField = {
       let label = NSTextField()
        label.placeholderString = "255"
        label.setupTextField()
        label.action = #selector(onTextEntered(_:))
        return label
    }()

    let gLabel: NSTextField = {
        let label = NSTextField()
        label.stringValue = "G"
        label.setAsLabel()
        return label
    }()

    let gColorField: NSTextField = {
       let label = NSTextField()
        label.placeholderString = "255"
        label.setupTextField()
        label.action = #selector(onTextEntered(_:))
        return label
    }()

    let bLabel: NSTextField = {
        let label = NSTextField()
        label.stringValue = "B"
        label.setAsLabel()
        return label
    }()

    let bColorField: NSTextField = {
       let label = NSTextField()
        label.placeholderString = "255"
        label.setupTextField()
        label.action = #selector(onTextEntered(_:))
        return label
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        colorGraphView = PrismColorGraphView()
        colorSliderView = PrismColorSliderView()
        colorSliderView.delegate = self
        colorGraphView.delegate = self
        hexColorField.delegate = self
        rColorField.delegate = self
        gColorField.delegate = self
        bColorField.delegate = self
        hexColorField.target = self
        rColorField.target = self
        gColorField.target = self
        bColorField.target = self

        view.addSubview(colorGraphView)
        view.addSubview(colorSliderView)
        view.addSubview(colorDropperIcon)
        view.addSubview(hashtagLabel)
        view.addSubview(hexColorField)
        view.addSubview(rLabel)
        view.addSubview(rColorField)
        view.addSubview(gLabel)
        view.addSubview(gColorField)
        view.addSubview(bLabel)
        view.addSubview(bColorField)

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        setupConstraints()

        setColor(newColor: PrismRGB(red: 1.0, green: 0, blue: 0))
    }

    private func setupConstraints() {
        colorGraphView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        colorGraphView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        colorSliderView.leadingAnchor.constraint(equalTo: colorGraphView.trailingAnchor, constant: 14).isActive = true
        colorSliderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        colorSliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        colorSliderView.widthAnchor.constraint(equalToConstant: 26).isActive = true
        colorSliderView.heightAnchor.constraint(equalTo: colorGraphView.heightAnchor).isActive = true

        colorDropperIcon.leadingAnchor.constraint(equalTo: colorGraphView.leadingAnchor).isActive = true
        colorDropperIcon.topAnchor.constraint(equalTo: colorGraphView.bottomAnchor, constant: 10).isActive = true
        colorDropperIcon.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true

        hashtagLabel.leadingAnchor.constraint(equalTo: colorDropperIcon.trailingAnchor).isActive = true
        hashtagLabel.topAnchor.constraint(equalTo: colorDropperIcon.topAnchor).isActive = true
        hashtagLabel.bottomAnchor.constraint(equalTo: colorDropperIcon.bottomAnchor).isActive = true

        hexColorField.leadingAnchor.constraint(equalTo: hashtagLabel.trailingAnchor, constant: 4).isActive = true
        hexColorField.topAnchor.constraint(equalTo: hashtagLabel.topAnchor).isActive = true
        hexColorField.widthAnchor.constraint(equalToConstant: 58).isActive = true
        hexColorField.bottomAnchor.constraint(equalTo: hashtagLabel.bottomAnchor).isActive = true

        rLabel.leadingAnchor.constraint(equalTo: hexColorField.trailingAnchor, constant: 8).isActive = true
        rLabel.topAnchor.constraint(equalTo: hexColorField.topAnchor).isActive = true
        rLabel.bottomAnchor.constraint(equalTo: hexColorField.bottomAnchor).isActive = true

        rColorField.leadingAnchor.constraint(equalTo: rLabel.trailingAnchor, constant: 4).isActive = true
        rColorField.topAnchor.constraint(equalTo: rLabel.topAnchor).isActive = true
        rColorField.widthAnchor.constraint(equalToConstant: 28).isActive = true
        rColorField.bottomAnchor.constraint(equalTo: rLabel.bottomAnchor).isActive = true

        gLabel.leadingAnchor.constraint(equalTo: rColorField.trailingAnchor, constant: 8).isActive = true
        gLabel.topAnchor.constraint(equalTo: rColorField.topAnchor).isActive = true
        gLabel.bottomAnchor.constraint(equalTo: rColorField.bottomAnchor).isActive = true

        gColorField.leadingAnchor.constraint(equalTo: gLabel.trailingAnchor, constant: 4).isActive = true
        gColorField.topAnchor.constraint(equalTo: gLabel.topAnchor).isActive = true
        gColorField.widthAnchor.constraint(equalToConstant: 28).isActive = true
        gColorField.bottomAnchor.constraint(equalTo: gLabel.bottomAnchor).isActive = true

        bLabel.leadingAnchor.constraint(equalTo: gColorField.trailingAnchor, constant: 8).isActive = true
        bLabel.topAnchor.constraint(equalTo: gColorField.topAnchor).isActive = true
        bLabel.bottomAnchor.constraint(equalTo: gColorField.bottomAnchor).isActive = true

        bColorField.leadingAnchor.constraint(equalTo: bLabel.trailingAnchor, constant: 4).isActive = true
        bColorField.topAnchor.constraint(equalTo: bLabel.topAnchor).isActive = true
        bColorField.widthAnchor.constraint(equalToConstant: 28).isActive = true
        bColorField.trailingAnchor.constraint(equalTo: colorSliderView.trailingAnchor).isActive = true
        bColorField.bottomAnchor.constraint(equalTo: bLabel.bottomAnchor).isActive = true
    }

    public func setColor(newColor: PrismHSB) {
        updateTextLabel(newColor: newColor.toRGB())
        updateColorGraphAndSlider(newColor: newColor)
    }

    public func setColor(newColor: PrismRGB) {
        updateTextLabel(newColor: newColor)
        updateColorGraphAndSlider(newColor: newColor.toHSV())
    }

    @objc private func onTextEntered(_ textField: NSTextField) {
        let stringValue = textField.stringValue
        if textField == hexColorField {
            let color = PrismRGB(hexString: stringValue)
            setColor(newColor: color)
        } else {
            guard let rInt = Int(rColorField.stringValue) else { return }
            guard let gInt = Int(gColorField.stringValue) else { return }
            guard let bInt = Int(bColorField.stringValue) else { return }
            let color = PrismRGB(red: rInt, green: gInt, blue: bInt)
            setColor(newColor: color)
        }
        view.window?.makeFirstResponder(view)
    }
}

// MARK: Updates Color picker based on set color method
extension PrismColorPicker {

    private func updateGraphViewFromSlider(newColor: PrismHSB) {
        guard let originalColor = colorGraphView.color.copy() as? PrismHSB else { return }
        let modifiedColor = PrismHSB(hue: newColor.hue,
                                     saturation: originalColor.saturation,
                                     brightness: originalColor.brightness)
        colorGraphView.color = modifiedColor
    }

    private func updateTextLabel(newColor: PrismRGB) {
        let red = Int(newColor.red * 255)
        let green = Int(newColor.green * 255)
        let blue = Int(newColor.blue * 255)
        rColorField.stringValue = "\(red)"
        gColorField.stringValue = "\(green)"
        bColorField.stringValue = "\(blue)"

        hexColorField.stringValue = String(format: "%02X%02X%02X",
                                           red,
                                           green,
                                           blue
        )
    }

    private func updateColorGraphAndSlider(newColor: PrismHSB) {
        colorGraphView.color = newColor
        guard let modifiedColor = newColor.copy() as? PrismHSB else { return }
        modifiedColor.saturation = 1
        modifiedColor.brightness = 1
        colorSliderView.color = modifiedColor
    }
}

extension PrismColorPicker: PrismColorSliderDelegate, PrismColorGraphDelegate {

    func didColorChange(color: PrismHSB, mouseUp: Bool) {
        let toRGB = color.toRGB()
        updateTextLabel(newColor: toRGB)
        delegate?.didColorChange(newColor: toRGB, finishedChanging: mouseUp)
    }

    func didHueChanged(newColor: PrismHSB, mouseUp: Bool) {
        updateGraphViewFromSlider(newColor: newColor)
        let rgb = colorGraphView.color.toRGB()
        updateTextLabel(newColor: rgb)
        delegate?.didColorChange(newColor: rgb, finishedChanging: mouseUp)
    }
}

public protocol PrismColorPickerDelegate: AnyObject {
    func didColorChange(newColor: PrismRGB, finishedChanging: Bool)
}

extension NSTextField {

    func setupTextField() {
        self.drawsBackground = false
        self.isEditable = true
        self.isBordered = false
        self.isBezeled = false
        self.font = NSFont.boldSystemFont(ofSize: 14)
        self.refusesFirstResponder = true
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    func setAsLabel() {
        self.isEditable = false
        self.isBezeled = false
        self.isBordered = false
        self.drawsBackground = false
        self.isSelectable = false
        self.textColor = NSColor.secondaryLabelColor
        self.font = NSFont.systemFont(ofSize: 14)
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

}

extension PrismColorPicker: NSTextFieldDelegate {

    private func hexColorValidation(_ string: String) -> Bool {
        return string.count == 6 && string.isHexadecimalChar
    }

    private func intColorRangeValidation(_ string: String) -> Bool {
        if string.count <= 3 && string.isNumeric {
            guard let intVal = Int(string) else { return false }
            return 0 <= intVal && intVal <= 255
        }
        return false
    }

    public func isValid(_ control: NSControl, isValidObject obj: Any?) -> Bool {
        if control == hexColorField {
            guard let string = obj as? String else { return false }
            return hexColorValidation(string)
        } else {
            guard let string = obj as? String else { return false }
            return intColorRangeValidation(string)
        }
    }

    public func controlTextDidBeginEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        oldStringBeforeEditing = textField.stringValue
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        let isTextValid = isValid(textField, isValidObject: textField.stringValue)
        if !isTextValid {
            textField.stringValue = self.oldStringBeforeEditing
        }
        textField.resignFirstResponder()
        oldStringBeforeEditing = ""
    }

    public func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        if textField == hexColorField {
            if textField.stringValue.count > 6 {
                textField.stringValue.removeLast()
            }
            textField.stringValue = textField.stringValue.uppercased()
        } else {
            if textField.stringValue.count > 3 {
                textField.stringValue.removeLast()
            }
        }
    }
}

extension String {
    var isNumeric: Bool {
        return !contains {
            switch $0 {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                return false
            default:
                return true
            }
        }
    }
    var isHexadecimalChar: Bool {
        return !contains {
            switch $0 {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "a", "b",
                 "c", "d", "e", "f":
                return false
            default:
                return true
            }
        }
    }
}
