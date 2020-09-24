//
//  PrismTransition.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/23/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public class PrismTransition: NSObject, Codable {
    var color = PrismRGB()
    var duration: UInt16 = 0

    public init(color: PrismRGB, duration: UInt16) {
        self.color = color
        self.duration = duration
    }
}

extension PrismTransition {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherTransition = object as? PrismTransition else { return false }
        return self.color == otherTransition.color &&
            self.duration == otherTransition.duration
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(color)
        hasher.combine(duration)
        return hasher.finalize()
    }
}
