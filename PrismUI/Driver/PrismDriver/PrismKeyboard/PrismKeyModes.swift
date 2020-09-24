//
//  PrismModes.swift
//  PrismUI
//
//  Created by Erik Bautista on 8/15/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public enum PrismKeyModes: UInt32, Codable {
    case steady
    case colorShift
    case breathing
    case reactive
    case disabled
}

extension PrismKeyModes: CustomStringConvertible {
    public var description: String {
        switch self {
        case .steady: return "Steady"
        case .colorShift: return "ColorShift"
        case .breathing: return "Breathing"
        case .reactive: return "Reactive"
        case .disabled: return "Disabled"
        }
    }
}
