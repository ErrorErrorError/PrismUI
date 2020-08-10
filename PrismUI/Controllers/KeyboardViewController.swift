//
//  PerKeyViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa
import PrismDriver

class KeyboardViewController: BaseViewController {

    var keys: NSMutableArray = NSMutableArray()

    override func loadView() {
        view = DragSelectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        (self.view as? NSVisualEffectView)?.material = .contentBackground
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard let prismDevice = PrismDriver.shared.prismDevice else { return }
        Log.debug("test")
        setupKeyboardLayout(model: prismDevice.model)
    }

    func setupKeyboardLayout(model: PrismDeviceModel) {
        guard model != .threeRegion else {
            return
        }

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
                    let key = KeyColorView(text: keyChar)
                    key.frame = NSRect(x: xPos + padding, y: yPos - padding, width: keyWidth, height: keyHeight)
                    key.delegate = self
                    key.color = .red
                    return key
                }()
                self.view.addSubview(keyView)
                xPos += desiredKeyWidth * widthFract

//                let keycode = keycodeArray[index][subIndex]
//                self.keys.add(PrismKey(region: getRegionKey(keyChar, keycode: keycode),
//                                            keycode: keycode,
//                                            effectId: 0,
//                                            duration: 0,
//                                            mainColor: prism_rgb(r: 255, g: 0, b: 0),
//                                            activeColor: prism_rgb(r: 0, g: 0, b: 0),
//                                            mode: steady
//                    )
//                )
            }
            xPos = xOffset
            yPos -= desiredKeyHeight
        }
    }

//    private func getRegionKey(_ char: String, keycode: UInt8) -> UInt8 {
//        var region: UInt8
//        switch char {
//        case "ESC":
//            region = regions.0
//        case "A":
//            region = regions.1
//        case "ENTER":
//            region = regions.2
//        case "F7":
//            region = regions.3
//        default:
//            region = get_region_from_key(keycode)
//        }
//        return region
//    }
}

extension KeyboardViewController: ColorViewDelegate {
    func didSelect(_ sender: ColorView) {
//        let index = view.subviews.firstIndex(of: sender)!
//        print(sender)
    }

    func didDeselect(_ sender: ColorView) {
//        let index = view.subviews.firstIndex(of: sender)!
//        print(sender)
    }
}
