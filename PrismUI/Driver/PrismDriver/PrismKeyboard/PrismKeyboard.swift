//
//  PrismKeyboard.swift
//  PrismUI
//
//  Created by Erik Bautista on 8/15/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public final class PrismKeyboard: PrismDevice {

    // Keys array

    static let keys = NSMutableArray()

    // Selected KeyColorView array

    static let keysSelected = NSMutableArray()

    // Effects array

    static let effects = NSMutableArray()

    // MARK: GS65 and PerKey - Region keys

    static let regions: [UInt8] = [
        0x18,   // esc (modifiers)
        0x2a,   // a (alphanums)
        0x0b,   // enter (enter)
        0x24    // f7 (special/numpad)
    ]

    // MARK: GS65 and PerKey - Modifier Keys

    static let modifiers: [UInt8] = [
        0x29,   // backspace
        0x2a,   // tab
        0x2b,   // spacebar
        0x2c,   // -
        0x2d,   // =
        0x2e,   // [
        0x2f,   // ]
        0x30,   // ;
        0x33,   // '
        0x34,   // ~
        0x35,   // ,
        0x36,   // .
        0x37,   // /
        0x38,   // capslock
        0x39,   // NULL
        0x65,   // lctrl
        0xe0,   // lshift
        0xe1,   // lalt
        0xe2,   // win key
        0xe3,   // rctrl
        0xe4,   // rshift
        0xe5,   // ralt
        0xe6,   // fn
        0xf0    // NULL
    ]

    // MARK: GS65 and PerKey - Alphanums Keys

    static let alphanums: [UInt8] = [
        0x04,   // b
        0x05,   // c
        0x06,   // d
        0x07,   // e
        0x08,   // f
        0x09,   // g
        0x0a,   // h
        0x0b,   // i
        0x0c,   // j
        0x0d,   // k
        0x0e,   // l
        0x0f,   // m
        0x10,   // n
        0x11,   // o
        0x12,   // p
        0x13,   // q
        0x14,   // r
        0x15,   // s
        0x16,   // t
        0x17,   // u
        0x18,   // v
        0x19,   // w
        0x1a,   // x
        0x1b,   // y
        0x1c,   // z
        0x1d,   // 1
        0x1e,   // 2
        0x1f,   // 3
        0x20,   // 4
        0x21,   // 5
        0x22,   // 6
        0x23,   // 7
        0x24,   // 8
        0x25,   // 9
        0x26,   // 0
        0x27,   // f1
        0x3a,   // f2
        0x3b,   // f3
        0x3c,   // f4
        0x3d,   // f5
        0x3e,   // f6
        0x3f    // NULL
    ]

    // MARK: GS65 and PerKey - Enter Keys

    static let enter: [UInt8] = [
        0x28,   // backslash
        0x31,   // NULL
        0x32,   // backslash (next to spacebar)
        0x64,   // NULL
        0x87,   // NULL
        0x88,   // NULL
        0x89,   // NULL
        0x8A,   // NULL
        0x8B,   // NULL
        0x90,   // NULL
        0x91    // NULL
    ]

    // MARK: PerKey - Special keys

    static let special: [UInt8] = [
        0x40,   // F8
        0x41,   // F9
        0x42,   // F10
        0x43,   // F11
        0x44,   // F12
        0x45,   // prtscr
        0x46,   // scroll lock
        0x47,   // pause/break
        0x48,   // insert
        0x49,   // NULL
        0x4a,   // pgup
        0x4b,   // delete
        0x4c,   // NULL
        0x4d,   // pgdn
        0x4e,   // right arrow
        0x4f,   // left arrow
        0x50,   // down arrow
        0x51,   // up arrow
        0x52,   // num lock
        0x53,   // / - numpad
        0x54,   // * - numpad
        0x55,   // minus - numpad
        0x56,   // plus - numpad
        0x57,   // enter - numpad
        0x58,   // 1 - numpad
        0x59,   // 2 - numpad
        0x5a,   // 3 - numpad
        0x5b,   // 4 - numpad
        0x5c,   // 5 - numpad
        0x5d,   // 6 - numpad
        0x5e,   // 7 - numpad
        0x5f,   // 8 - numpad
        0x60,   // 9 - numpad
        0x61,   // 0 - numpad
        0x62,   // . - numpad
        0x63    // NULL
    ]

    // MARK: GS65 Special keys, similar to per key but less keys

    static let specialGS65: [UInt8] = [
        0x40,   // F8
        0x41,   // F9
        0x42,   // F10
        0x43,   // F11
        0x44,   // F12
        0x45,   // prtscr
        0x46,   // NULL
        0x47,   // NULL
        0x48,   // NULL
        0x49,   // home
        0x4a,   // pgup
        0x4b,   // del (insert)
        0x4c,   // end
        0x4d,   // pgdn
        0x4e,   // right arrow
        0x4f,   // left arrow
        0x50,   // down arrow
        0x51,   // up arrow
        0x52    // NULL
    ]

    static func getRegionFromKeycode(_ keycode: UInt8) -> UInt8 {
        for key in modifiers where key == keycode {
            return regions[0]
        }

        for key in alphanums where key == keycode {
            return regions[1]
        }

        for key in enter where key == keycode {
            return regions[2]
        }

        for key in special where key == keycode {
            return regions[3]
        }

        return 0
    }

    public override func update() {
        Log.debug("Updating \(model)")
        if model != .threeRegion {
            updatePerKeyKeyboard()
        } else {
            // TODO: Update three region keyboard
        }
    }

}

extension PrismKeyboard {

    private func updateEffectKeyboard() -> IOReturn {
        let effects = PrismKeyboard.effects.compactMap { $0 as? PrismEffect }
        guard effects.count > 0 else { return kIOReturnNotFound }

        for effect in effects {
            var data = Data(capacity: 0x20c)
            data.append([0x0b, 0x0], count: 2) // Start Packet
            guard effect.transitions.count > 0 else {
                // Must have at least one transition or will throw error
                return kIOReturnError
            }

            // Transitions - each transition will take 8 bytes
            let transitions = effect.transitions
            for (index, transition) in transitions.enumerated() {
                let idx = UInt8(index)
                data.append([index == 0 ? effect.identifier : idx], count: 1)

                // Calculate color difference
                let nextColor = (index + 1) < transitions.count ? transitions[index + 1].color : effect.start
                let colorDelta = transition.color.colorDelta(target: nextColor, duration: transition.duration)

                data.append([0x0,
                             colorDelta.redInt,
                             colorDelta.greenInt,
                             colorDelta.blueInt,
                             0x0,

                             // Separates the duration into two bytes
                             UInt8(transition.duration & 0x00ff),
                             UInt8((transition.duration & 0xff00) >> 8)
                ], count: 7)
            }

            // Fill spaces
            var fillZeros = [UInt8](repeating: 0x00, count: 0x84 - data.count)
            data.append(fillZeros, count: fillZeros.count)

            // Set starting color, each value will have 2 bytes
            data.append([(effect.start.redInt & 0x0f) << 4,
                         (effect.start.redInt & 0xf0) >> 4,
                         (effect.start.greenInt & 0x0f) << 4,
                         (effect.start.greenInt & 0xf0) >> 4,
                         (effect.start.blueInt & 0x0f) << 4,
                         (effect.start.blueInt & 0xf0) >> 4,
                         // Separator
                         0xff,
                         0x00
            ], count: 8)

            // Wave mode

            if effect.waveActive {
                let origin = effect.origin
                             // Split origin into two bytes
                data.append([UInt8(origin.xAxis & 0x00ff),
                             UInt8((origin.xAxis & 0xff00) >> 8),
                             UInt8(origin.yAxis & 0x00ff),
                             UInt8((origin.yAxis & 0xff00) >> 8),
                             // Direction Control
                             effect.direction != .yAxis ? 0x01 : 0x00,
                             0x00,
                             effect.direction != .xAxis ? 0x01 : 0x00,
                             0x00,
                             // Wave Length
                             UInt8(effect.pulse & 0x00ff),
                             UInt8((effect.pulse & 0xff00) >> 8)
                ], count: 10)
            } else {
                fillZeros = [UInt8](repeating: 0x00, count: 10)
                data.append(fillZeros, count: fillZeros.count)
            }
                         // Transition count
            data.append([UInt8(effect.transitions.count),
                         0x00,
                         // Total effect length
                         UInt8(effect.transitionDuration & 0x00ff),
                         UInt8((effect.transitionDuration & 0xff00) >> 8),
                         // Wave Direction
                         effect.control == .inward ? 0x01 : 0x00
            ], count: 5)

            // Fill remaining with zeros
            fillZeros = [UInt8](repeating: 0x00, count: 0x20c - data.count)
            data.append(fillZeros, count: fillZeros.count)

            let result = sendFeatureReport(data: data)
            guard result == kIOReturnSuccess else {
                Log.debug("Could not send effect report: \(String(cString: mach_error_string(result)))")
                return result
            }
        }

        return kIOReturnSuccess
    }

    private func updatePerKeyKeyboard() {
        commandMutex.async {
            let keysSelected = PrismKeyboard.keysSelected
                .compactMap { $0 as? KeyColorView }
                .compactMap { $0.prismKey }
            guard keysSelected.count > 0 else { return }

            let updateModifiers = keysSelected.filter { $0.region == PrismKeyboard.regions[0] }.count > 0
            let updateAlphanums = keysSelected.filter { $0.region == PrismKeyboard.regions[1] }.count > 0
            let updateEnter = keysSelected.filter { $0.region == PrismKeyboard.regions[2] }.count > 0
            let updateSpecial = keysSelected.filter { $0.region == PrismKeyboard.regions[3] }.count > 0

            // Update effects first
            let result = self.updateEffectKeyboard()
            guard result == kIOReturnSuccess || result == kIOReturnNotFound else {
                Log.error("Cannot update effect: \(String(cString: mach_error_string(result)))")
                return
            }

            // Send feature report
            var lastByte: UInt8 = 0
            if updateModifiers {
                lastByte = 0x2d
                self.writeKeyFeatureReport(region: PrismKeyboard.regions[0], keycodes: PrismKeyboard.modifiers)
            }

            if updateAlphanums {
                lastByte = 0x08
                self.writeKeyFeatureReport(region: PrismKeyboard.regions[1], keycodes: PrismKeyboard.alphanums)
            }

            if updateEnter {
                lastByte = 0x87
                self.writeKeyFeatureReport(region: PrismKeyboard.regions[2], keycodes: PrismKeyboard.enter)
            }

            if updateSpecial {
                lastByte = 0x44
                self.writeKeyFeatureReport(region: PrismKeyboard.regions[3],
                                           keycodes: self.model == .perKey ?
                                            PrismKeyboard.special :
                                            PrismKeyboard.specialGS65)
            }

            // Update keyboard
            self.writeToKeyboard(lastByte: lastByte)
        }
    }

    private func writeToKeyboard(lastByte: UInt8) {
        var data = Data(capacity: 0x40)

        data.append([0x0d, 0x0, 0x02], count: 3)
        data.append([UInt8](repeating: 0, count: 60), count: 60)
        data.append([lastByte], count: 1)
        let result = write(data: data)
        if result != kIOReturnSuccess {
            Log.error("Error writing keyboard: \(String(cString: mach_error_string(result)))")
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
        let sizeRemaining = 0x20c - data.count
        data.append([UInt8](repeating: 0, count: sizeRemaining), count: sizeRemaining)
        let result = sendFeatureReport(data: data)
        if result != kIOReturnSuccess {
            Log.error("Error updating keyboard: \(String(cString: mach_error_string(result)))")
        }
    }
}

enum PrismError: Error {
    case runtimeError(String)
}
