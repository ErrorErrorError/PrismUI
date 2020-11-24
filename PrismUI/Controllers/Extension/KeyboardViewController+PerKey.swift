//
//  KeyboardViewController + PerKey.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/8/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

extension KeyboardViewController {

    func setupPerKeyLayout(model: PrismDeviceModel) {
        let keyboardMap = model == .perKey ? KeyboardLayout.perKeyMap : KeyboardLayout.perKeyGS65KeyMap
        let keyboardKeyNames = model == .perKey ? KeyboardLayout.perKeyNames : KeyboardLayout.perKeyGS65KeyNames
        let keycodeArray = (model == .perKey ? KeyboardLayout.perKeyCodes : KeyboardLayout.perKeyGS65KeyCodes)
        let padding: CGFloat = 5
        let desiredKeyWidth: CGFloat = model == .perKey ? 50 : 60
        let desiredKeyHeight = desiredKeyWidth
        let keyboardHeight = 6 * desiredKeyHeight
        let keyboardWidth = ((model == .perKey) ? 20 : 15) * desiredKeyWidth
        let xOffset: CGFloat = (view.frame.width - keyboardWidth) / 2
        var xPos: CGFloat = xOffset
        var yPos: CGFloat = (view.frame.height - keyboardHeight) / 2 + keyboardHeight - desiredKeyHeight

        for (index, row) in keyboardMap.enumerated() {
            for (subIndex, widthFract) in row.enumerated() {
                let isDoubleHeight = model == .perKey && (index == 3 || index == 5) && (subIndex + 1 == row.count)
                let keyWidth = (desiredKeyWidth * widthFract) - padding
                let keyHeight = (isDoubleHeight ? (2 * desiredKeyHeight) - padding : desiredKeyHeight - padding)
                let keyChar = keyboardKeyNames[index][subIndex]
                let keyView: KeyColorView = {
                    let keycode = keycodeArray[index][subIndex]
                    let prismKey = PrismKey(region: getRegionKey(keyChar, keycode: keycode), keycode: keycode)
                    let key = KeyColorView(text: keyChar, key: prismKey)
                    key.frame = NSRect(x: xPos + padding, y: yPos - padding, width: keyWidth, height: keyHeight)
                    key.delegate = self
                    return key
                }()
                PrismKeyboardDevice.keys.add(keyView.prismKey!)
                view.addSubview(keyView)
                xPos += desiredKeyWidth * widthFract
            }
            xPos = xOffset
            yPos -= desiredKeyHeight
        }

        let keyboardFrame = NSRect(x: xOffset + padding,
                           y: (view.frame.height - keyboardHeight) / 2 - padding,
                           width: keyboardWidth - padding,
                           height: keyboardHeight - padding)
        originView = OriginEffectView(frame: keyboardFrame)
        originView?.isHidden = true
        view.addSubview(originView!)

        NotificationCenter.default.addObserver(self, selector: #selector(handleOriginToggle),
                                               name: .prismOriginToggled, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateOriginView),
                                               name: .updateOriginView, object: nil)
    }

    private func getRegionKey(_ char: String, keycode: UInt8) -> UInt8 {
        var region: UInt8
        switch char {
        case "ESC":
            region = PrismKeyboardDevice.regions[0]
        case "A":
            region = PrismKeyboardDevice.regions[1]
        case "ENTER":
            region = PrismKeyboardDevice.regions[2]
        case "F7":
            region = PrismKeyboardDevice.regions[3]
        default:
            region = PrismKeyboardDevice.getRegionFromKeycode(keycode)
        }
        return region
    }
}

extension KeyboardViewController {

    @objc func handleOriginToggle(notification: Notification) {
        guard let originView = originView else { return }
        if let shouldHide = notification.object as? Bool {
            originView.isHidden = shouldHide
        } else {
            originView.isHidden = !originView.isHidden
        }
    }

    @objc func updateOriginView(notification: Notification) {
        guard let originView = originView else { return }
        if let point = notification.object as? PrismPoint {
            originView.setOrigin(origin: point)
        } else if let type = notification.object as? PrismDirection {
            originView.typeOfRad = type
        } else if let transitions = notification.object as? [PrismTransition] {
            originView.colorArray = transitions.compactMap { $0.color.nsColor }
        }
    }
}

extension KeyboardViewController: ColorViewDelegate {

    func didSelect(_ sender: ColorView) {
        if !PrismKeyboardDevice.keysSelected.contains(sender) {
            PrismKeyboardDevice.keysSelected.add(sender)
        }
    }

    func didDeselect(_ sender: ColorView) {
        if PrismKeyboardDevice.keysSelected.contains(sender) {
            PrismKeyboardDevice.keysSelected.remove(sender)
        }
    }
}

// MARK: Notification broadcast

extension Notification.Name {
    public static let prismEffectOriginChanged: Notification.Name = .init(rawValue: "prismEffectOriginChanged")
}
