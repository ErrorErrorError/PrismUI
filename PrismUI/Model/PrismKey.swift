//
//  PrismKeys.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/15/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public class PrismKey {
    let region: UInt8
    let keycode: UInt8
    var effect: PrismEffect?
    var duration: UInt16 = 0x012c
    var main = PrismRGB(red: 1.0, green: 0.0, blue: 0.0)
    var active = PrismRGB()
    var mode: PrismKeyModes = .steady {
        willSet(value) {
            guard value != mode else { return }
            switch value {
            case .steady:
                self.effect = nil
                self.duration = 0x012c
                self.main = PrismRGB()
                self.active = PrismRGB()
            case .colorShift:
                break
            case .breathing:
                break
            case .reactive:
                self.effect = nil
                self.duration = 0x012c
                self.main = PrismRGB()
                self.active = PrismRGB()
            case .disabled:
                break
            }
        }
    }

    init(region: UInt8, keycode: UInt8) {
        self.region = region
        self.keycode = keycode
    }
}
