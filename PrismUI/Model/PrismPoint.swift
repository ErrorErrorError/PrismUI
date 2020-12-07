//
//  PrismPoint.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/23/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public final class PrismPoint: NSObject {
    var xPoint: CGFloat = 0
    var yPoint: CGFloat = 0

    var xUInt16: UInt16 {
        return min(UInt16.max, max(UInt16(xPoint * 0x105C), 0))
    }

    var yUInt16: UInt16 {
        return min(UInt16.max, max(UInt16(yPoint * 0x040D), 0))
    }

    convenience init(xPoint: UInt16, yPoint: UInt16) {
        self.init(xPoint: CGFloat(xPoint) / 0x105C, yPoint: CGFloat(yPoint) / 0x040D)
    }

    public init(xPoint: CGFloat, yPoint: CGFloat) {
        self.xPoint = min(1.0, max(xPoint, 0))
        self.yPoint = min(1.0, max(yPoint, 0))
    }

    convenience override init() {
        self.init(xPoint: 0.0, yPoint: 0.0)
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

extension PrismPoint: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = PrismPoint(xPoint: xPoint, yPoint: yPoint)
        return copy
    }
}

extension PrismPoint: Codable {

    private enum CodingKeys: String, CodingKey {
        case xAxis, yAxis
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let xVal = try container.decodeIfPresent(CGFloat.self, forKey: .xAxis) ?? 0
        let yVal = try container.decodeIfPresent(CGFloat.self, forKey: .yAxis) ?? 0
        self.init(xPoint: xVal, yPoint: yVal)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(xPoint, forKey: .xAxis)
        try container.encode(yPoint, forKey: .yAxis)
    }
}
