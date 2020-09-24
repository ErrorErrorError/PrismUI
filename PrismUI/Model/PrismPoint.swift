//
//  PrismPoint.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/23/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public class PrismPoint: NSObject, Codable {
    var xAxis: UInt16 = 0
    var yAxis: UInt16 = 0

    public init(xAxis: UInt16, yAxis: UInt16) {
        self.xAxis = xAxis
        self.yAxis = yAxis
    }

    convenience override init() {
        self.init(xAxis: 0, yAxis: 0)
    }
}

extension PrismPoint {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherPoint = object as? PrismPoint else { return false }
        return self.xAxis == otherPoint.xAxis &&
            self.yAxis == otherPoint.yAxis
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(xAxis)
        hasher.combine(yAxis)
        return hasher.finalize()
    }
}
