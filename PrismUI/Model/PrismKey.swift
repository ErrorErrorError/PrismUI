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
    var mainColor: prism_rgb = prism_rgb()
    var activeColor: prism_rgb = prism_rgb()
    var mode: per_key_modes = steady
}
