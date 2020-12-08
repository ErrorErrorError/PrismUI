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
    var position: CGFloat = 0x21 / 0xBB8

    public init(color: PrismRGB, position: CGFloat) {
        self.color = color
        self.position = position
    }
}

extension PrismTransition {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherTransition = object as? PrismTransition else { return false }
        return self.color == otherTransition.color &&
            self.position == otherTransition.position
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(color)
        hasher.combine(position)
        return hasher.finalize()
    }
}
