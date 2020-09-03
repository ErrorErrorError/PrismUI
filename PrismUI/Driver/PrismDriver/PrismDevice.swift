//
//  PrismDriver.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/20/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public class PrismDevice: Equatable {
    public static func == (lhs: PrismDevice, rhs: PrismDevice) -> Bool {
        lhs.device.identification == rhs.device.identification
    }

    let device: HIDDevice
    public let model: PrismDeviceModel

    var isKeyboardDevice: Bool {
        return model == .perKeyGS65 || model == .perKey || model == .threeRegion
    }

    public init(device: HIDDevice) throws {
        self.device = device
        self.model = try device.getPrismDeviceModel()
    }

    public func update() {
        Log.debug("Cannot update unknown device: \(device.identification)")
    }
}
