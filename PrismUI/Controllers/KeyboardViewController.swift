//
//  PerKeyViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import Cocoa

class KeyboardViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setuPerKeyboardLayout(isPerKey: true)
    }

    func setuPerKeyboardLayout(isPerKey: Bool) {
        let keyboardMap = isPerKey ? KeyboardLayout.PerKeymap : KeyboardLayout.GS65Keymap
        let keyboardKeyNames = isPerKey ? KeyboardLayout.PerKeyNames : KeyboardLayout.GS65KeyNames
        let padding: CGFloat = 5
        let desiredKeyWidth: CGFloat = isPerKey ? 50 : 60
        let desiredKeyHeight = desiredKeyWidth
        let xOffset: CGFloat = isPerKey ? 15 : 65
        let keyboardHeight = 6 * desiredKeyHeight
        var xPos = xOffset
        var yPos: CGFloat = (720 - keyboardHeight) / 2 + keyboardHeight - desiredKeyHeight
        for (index, row) in keyboardMap.enumerated() {
            for (subIndex, widthFract) in row.enumerated() {
                let isDoubleHeight = isPerKey && (index == 3 || index == 5) && (subIndex + 1 == row.count)
                let keyWidth = (desiredKeyWidth * widthFract) - padding
                let keyHeight = (isDoubleHeight ? (2 * desiredKeyHeight) - padding : desiredKeyHeight - padding)
                let keyChar = keyboardKeyNames[index][subIndex]
                let keyView = KeyColorView(color: .red, text: keyChar)
                keyView.frame = NSRect(x: xPos + padding, y: yPos - padding, width: keyWidth, height: keyHeight)
                self.view.addSubview(keyView)
                xPos += desiredKeyWidth * widthFract
            }
            xPos = xOffset
            yPos -= desiredKeyHeight
        }

    }

}
