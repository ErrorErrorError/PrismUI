//
//  PrismKeyboard.swift
//  PrismUI
//
//  Created by Erik Bautista on 8/15/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public final class PrismKeyboard {

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
}
