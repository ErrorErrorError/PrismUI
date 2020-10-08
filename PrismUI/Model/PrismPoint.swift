//
//  PrismPoint.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/23/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public final class PrismPoint: NSObject {
    var xPoint: UInt16 = 0
    var yPoint: UInt16 = 0

    public init(xPoint: UInt16, yPoint: UInt16) {
        self.xPoint = xPoint
        self.yPoint = yPoint
    }

    convenience override init() {
        self.init(xPoint: 0, yPoint: 0)
    }
}

extension PrismPoint {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherPoint = object as? PrismPoint else { return false }
        return self.xPoint == otherPoint.xPoint &&
            self.yPoint == otherPoint.yPoint
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(xPoint)
        hasher.combine(yPoint)
        return hasher.finalize()
    }
}

extension PrismPoint: Codable {

    private enum CodingKeys: String, CodingKey {
        case xAxis, yAxis
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let xVal = try container.decodeIfPresent(UInt16.self, forKey: .xAxis) ?? 0
        let yVal = try container.decodeIfPresent(UInt16.self, forKey: .yAxis) ?? 0
        self.init(xPoint: xVal, yPoint: yVal)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(xPoint, forKey: .xAxis)
        try container.encode(yPoint, forKey: .yAxis)
    }
}
