//
//  PrismKeys.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/15/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

struct PrismKey {
    var region: UInt8 = 0
    var keycode: UInt8 = 0
    var effectId: UInt8 = 0
    var duration: UInt16 = 0
    var mainColor: PrismRGB = PrismRGB(red: 1.0, green: 0.0, blue: 0.0)
    var activeColor: PrismRGB = PrismRGB(red: 0, green: 0, blue: 0)
//    var mode: per_key_modes = steady
}
