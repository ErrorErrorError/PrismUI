//
//  PrismDriver.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/20/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public class PrismDevice {

    let commandMutex = DispatchQueue(label: "prism-command")

    public typealias RawDevice = WriteDevice & FeatureReportDevice

    // MARK: Device information

    private let device: RawDevice
    public let identification: Int
    public let name: String
    public let vendorId: Int
    public let versionNumber: Int
    public let productId: Int
    public let primaryUsagePage: Int

    // MARK: PrismDeviceModel

    public var model: PrismDeviceModel {
        let product = PrismDeviceModel.allCases.first(where: {
            $0.vendorId == self.vendorId &&
                $0.productId == self.productId &&
                $0.versionNumber == self.versionNumber &&
                $0.primaryUsagePage == self.primaryUsagePage
        })
        guard let model = product else {
            return .unknown
        }
        return model
    }

    var isKeyboardDevice: Bool {
        return model == .perKeyGS65 || model == .perKey || model == .threeRegion
    }

    internal init(device: IOHIDDevice) throws {
        self.device = device
        identification = try device.getProperty(key: kIOHIDLocationIDKey)
        name = try device.getProperty(key: kIOHIDProductKey)
        vendorId = try device.getProperty(key: kIOHIDVendorIDKey)
        productId = try device.getProperty(key: kIOHIDProductIDKey)
        primaryUsagePage = try device.getProperty(key: kIOHIDPrimaryUsagePageKey)
        versionNumber = try device.getProperty(key: kIOHIDVersionNumberKey)
    }

    public func update(forceUpdate: Bool = false) {
        Log.error("Update unknown device not implemented for: \(name):\(identification)")
    }
}

// MARK: Send Feature Report / Write

extension PrismDevice {
    func sendFeatureReport(data: Data) -> IOReturn {
        return device.sendFeatureReport(data: data)
    }

    func write(data: Data) -> IOReturn {
        return device.write(data: data)
    }
}

// MARK: Comparison

extension PrismDevice: Equatable {
    public static func == (lhs: PrismDevice, rhs: PrismDevice) -> Bool {
        lhs.identification == rhs.identification
    }
}

// MARK: String

extension PrismDevice: CustomStringConvertible {
    public var description: String {
        var description = ""
        description += "\nPrismDevice: (\(name))\n"
        description += "\tID: \(identification)\n"
        description += "\tVendor ID: \(vendorId)\n"
        description += "\tProduct ID: \(productId)\n"
        description += "\tPrimary Usage: \(primaryUsagePage)\n"
        description += "\tVersion Numbae: \(versionNumber)\n"
        return description
    }
}
