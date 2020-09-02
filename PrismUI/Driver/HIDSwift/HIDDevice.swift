//
//  HIDDevice.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/20/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//
// From https://github.com/Sherlouk/Codedeck/blob/master/Sources/HIDSwift/HIDDevice.swift

import Foundation
import IOKit.hid

public class HIDDevice {

    public typealias RawDevice = WriteDevice & FeatureReportDevice

    public let device: RawDevice
    public let identification: Int
    public let name: String
    public let vendorId: Int
    public let versionNumber: Int
    public let productId: Int
    public let primaryUsagePage: Int

    internal init(device: IOHIDDevice) throws {
        self.device = device

        identification = try device.getProperty(key: kIOHIDLocationIDKey)
        name = try device.getProperty(key: kIOHIDProductKey)
        vendorId = try device.getProperty(key: kIOHIDVendorIDKey)
        productId = try device.getProperty(key: kIOHIDProductIDKey)
        primaryUsagePage = try device.getProperty(key: kIOHIDPrimaryUsagePageKey)
        versionNumber = try device.getProperty(key: kIOHIDVersionNumberKey)
    }

    internal init(identification: Int,
                  name: String,
                  vendorId: Int,
                  productId: Int,
                  primaryUsage: Int,
                  versionNumber: Int,
                  device: RawDevice) {

        self.identification = identification
        self.name = name
        self.vendorId = vendorId
        self.productId = productId
        self.primaryUsagePage = primaryUsage
        self.versionNumber = versionNumber
        self.device = device
    }

    public var description: String {
        return """
        HIDDevice (\(name):
            ID: \(identification)
            Vendor ID: \(vendorId)
            Product ID: \(productId)
            Primary Usage: \(primaryUsagePage)
            Version Numbae: \(versionNumber)
        """
    }

    public func sendFeatureReport(data: Data) -> IOReturn {
        return device.sendFeatureReport(data: data)
    }

    public func write(data: Data) -> IOReturn {
        return device.write(data: data)
    }
}
