//
//  PrismEffects.swift
//  PrismUI
//
//  Created by Erik Bautista on 8/15/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

struct PrismTransition {
    var color: PrismRGB
    var duration: UInt16
}

struct PrismPoint {
    var xAxis: UInt16
    var yAxis: UInt16
}

enum PrismDirection {
    case outward
    case inward
}

enum PrismControl {
    case xyAxis
    case xAxis
    case yAxis
}

struct PrismEffect {
    var effectId: UInt16 = 0
    var startColor: PrismRGB = PrismRGB(red: 0, green: 0, blue: 0)
    var waveActive: Bool = false
    var direction: PrismDirection = .inward
    var control: PrismControl = .xyAxis
    var origin: PrismPoint = PrismPoint(xAxis: 0, yAxis: 0)
    var waveLength: UInt16 = 0
    var transitions: [PrismTransition]
}
