//
//  MathUtils.swift
//  PrismUI
//
//  Created by Erik Bautista on 10/8/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

class MathUtils {

    public static func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
        return min(max(value, lower), upper)
    }

    public static func map<T: FloatingPoint>(value: T, inMin: T, inMax: T, outMin: T, outMax: T) -> T {
        let numerator = (value - inMin) * (outMax - outMin)
        let denominator = (inMax - inMin)
        let divided = numerator / denominator
        return divided + outMin
    }
}
