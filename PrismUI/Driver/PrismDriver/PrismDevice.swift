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

    public init(device: HIDDevice) throws {
        self.device = device
        self.model = try device.getPrismDeviceModel()
    }

    public func update() {
        Log.debug("Updating keyboard")
        if model != .threeRegion {
            updatePerKeyKeyboard()
        } else {
            // TODO: Update three region keyboard
        }
    }

    private func updatePerKeyKeyboard() {
        DispatchQueue.global(qos: .background).async {
            let keysSelected = PrismKeyboard.keysSelected
                .compactMap { $0 as? KeyColorView }
                .compactMap { $0.prismKey }
            guard keysSelected.count > 0 else { return }

            let updateModifiers = keysSelected.filter { $0.region == PrismKeyboard.regions[0] }.count > 0
            let updateAlphanums = keysSelected.filter { $0.region == PrismKeyboard.regions[1] }.count > 0
            let updateEnter = keysSelected.filter { $0.region == PrismKeyboard.regions[2] }.count > 0
            let updateSpecial = keysSelected.filter { $0.region == PrismKeyboard.regions[3] }.count > 0

            var lastRegion = PrismKeyboard.regions[0]
            // Send feature report

            if updateModifiers {
                lastRegion = PrismKeyboard.regions[0]
                self.writeKeyFeatureReport(region: lastRegion, keycodes: PrismKeyboard.modifiers)
            }

            if updateAlphanums {
                lastRegion = PrismKeyboard.regions[1]
                self.writeKeyFeatureReport(region: lastRegion, keycodes: PrismKeyboard.alphanums)
            }

            if updateEnter {
                lastRegion = PrismKeyboard.regions[2]
                self.writeKeyFeatureReport(region: lastRegion, keycodes: PrismKeyboard.enter)
            }

            if updateSpecial {
                lastRegion = PrismKeyboard.regions[3]
                self.writeKeyFeatureReport(region: lastRegion,
                                           keycodes: self.model == .perKey ? PrismKeyboard.special : PrismKeyboard.specialGS65)
            }

            // Update keyboard

            self.writeToKeyboard(lastRegion: lastRegion)
        }
    }

    private func writeToKeyboard(lastRegion: UInt8) {
        var data = Data(capacity: 0x40)

        var lastByte: UInt8 = 0

        switch lastRegion {
        case PrismKeyboard.regions[0]:
            lastByte = 0x2d
        case PrismKeyboard.regions[1]:
            lastByte = 0x08
        case PrismKeyboard.regions[2]:
            lastByte = 0x87
        case PrismKeyboard.regions[3]:
            lastByte = 0x44
        default:
            lastByte = 0
        }

        data.append([0x0d, 0x0, 0x02], count: 3)
        data.append([UInt8](repeating: 0, count: 0x40 - (data.count + 1)), count: 0x40 - (data.count + 1))
        data.append([lastByte], count: 1)
        let result = device.write(data: data)
        if result != kIOReturnSuccess {
            Log.error("Error updating keyboard: \(result)")
        }
    }
    private func writeKeyFeatureReport(region: UInt8, keycodes: [UInt8]) {
        var data = Data(capacity: 0x20c)

        // This array contains only the usable keys
        let keyboardKeys = PrismKeyboard.keys.compactMap { $0 as? PrismKey }.filter { $0.region == region }

        for keyCode in [region] + keycodes {
            if let key = keyboardKeys.filter({ $0.keycode == keyCode }).first {
                var mode: UInt8 = 0
                switch key.mode {
                case .steady:
                    mode = 0x01
                case .reactive:
                    mode = 0x08
                case .disabled:
                    mode = 0x03
                default:
                    mode = 0
                }

                if key.keycode == key.region {
                    data.append([0x0e, 0x0, key.keycode, 0x0], count: 4)
                } else {
                    data.append([0x0, key.keycode], count: 2)
                }

                data.append([key.main.redInt,
                             key.main.greenInt,
                             key.main.blueInt,
                             key.active.redInt,
                             key.active.greenInt,
                             key.active.blueInt,
                             UInt8(key.duration & 0x00ff),
                             UInt8((key.duration & 0xff00) >> 8),
                             key.effect?.identifier ?? 0,
                             mode], count: 10)
            } else {
                data.append([0x0,
                             keyCode,
                             0, 0, 0, 0, 0, 0,
                             0x2c,
                             0x01,
                             0, 0], count: 12)
            }
        }

        // Fill rest of data with the remaining capacity
        data.append([UInt8](repeating: 0, count: 0x20c - data.count), count: 0x20c - data.count)
        let result = device.sendFeatureReport(data: data)
        if result != kIOReturnSuccess {
            Log.error("Error updating keyboard: \(result)")
        }
    }
}
