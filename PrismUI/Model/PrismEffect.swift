//
//  PrismEffects.swift
//  PrismUI
//
//  Created by Erik Bautista on 8/15/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public class PrismTransition: Equatable {
    public static func == (lhs: PrismTransition, rhs: PrismTransition) -> Bool {
        return lhs.color == rhs.color && lhs.duration == rhs.duration
    }

    var color = PrismRGB()
    var duration: UInt16 = 0

    public init(color: PrismRGB, duration: UInt16) {
        self.color = color
        self.duration = duration
    }
}

public class PrismPoint: Equatable {
    public static func == (lhs: PrismPoint, rhs: PrismPoint) -> Bool {
        return lhs.xAxis == rhs.xAxis && lhs.yAxis == rhs.yAxis
    }

    var xAxis: UInt16 = 0
    var yAxis: UInt16 = 0

    public init(xAxis: UInt16, yAxis: UInt16) {
        self.xAxis = xAxis
        self.yAxis = yAxis
    }

    convenience init() {
        self.init(xAxis: 0, yAxis: 0)
    }
}

public enum PrismDirection: UInt8 {
    case xyAxis = 0
    case xAxis = 1
    case yAxis = 2
}

public enum PrismControl: UInt8 {
    case outward = 0
    case inward = 1
}

public class PrismEffect: Equatable {
    public static func == (lhs: PrismEffect, rhs: PrismEffect) -> Bool {
        return lhs.start == rhs.start &&
            lhs.waveActive == rhs.waveActive &&
            lhs.direction == rhs.direction &&
            lhs.control == rhs.control &&
            lhs.origin == rhs.origin &&
            lhs.waveLength == rhs.waveLength &&
            lhs.transitions == rhs.transitions
    }

    let identifier: UInt8
    var start: PrismRGB = PrismRGB()
    var waveActive: Bool = false
    var direction: PrismDirection = .xyAxis
    var control: PrismControl = .inward
    var origin: PrismPoint = PrismPoint()
    var waveLength: UInt16 = 0
    var transitions: [PrismTransition]
    var transitionDuration: UInt16 {
        return transitions.compactMap { $0.duration }.reduce(0, +)
    }

    public init(identifier: UInt8, transitions: [PrismTransition]) {
        self.identifier = identifier
        self.transitions = transitions
        self.start = transitions[0].color
        waveActive = false
    }
}
