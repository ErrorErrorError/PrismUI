//
//  IOHIDDevice+FeatureReport.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/20/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import IOKit.hid

extension IOHIDDevice {

    public func sendFeatureReport(data: Data) -> IOReturn {

        guard IOHIDDeviceOpen(self, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess else {
            print("Could not open usb port")
            return kIOReturnNotOpen
        }

        let returnValue = IOHIDDeviceSetReport(
            self,
            kIOHIDReportTypeFeature,
            CFIndex(data[0]),
            [UInt8](data),
            data.count
        )

        Thread.sleep(forTimeInterval: 0.02)

        guard returnValue == kIOReturnSuccess else {
            print("Could not send feature report")
            return returnValue
        }

        guard IOHIDDeviceClose(self, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess else {
            print("Could not close usb port")
            return kIOReturnStillOpen
        }

        return kIOReturnSuccess
    }

}
