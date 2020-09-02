//
//  PrismKeys.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/15/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public struct PrismKey {
    let region: UInt8
    let keycode: UInt8
    var effect: PrismEffect?
    var duration: UInt16 = 0
    var main = PrismRGB(red: 1.0, green: 0.0, blue: 0.0)
    var active = PrismRGB(red: 0, green: 0, blue: 0)
    var mode: PrismModes = .steady
}
