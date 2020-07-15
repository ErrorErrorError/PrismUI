//
//  KeyboardLayout.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

final class KeyboardLayout {

    static let GS65Keymap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [0.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1],
        [0.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.25, 1],
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.75, 1],
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1, 1],
        [1.25, 1, 1, 4.75, 1, 1, 1, 1, 1, 1, 1]
    ]

    static let GS65KeyNames = [
        ["ESC", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "PRT", "DEL"],
        ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BACKSPACE", "HOME"],
        ["TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\", "PGUP"],
        ["CAPS", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "ENTER", "PGDN"],
        ["SHIFT", "Z", "X", "C", "V", "B", "N", "M", ", ", ".", "/", "SHIFT", "UP", "END"],
        ["CTRL", "WIN", "ALT", "SPACEBAR", "\\", "ALT", "FN", "CTRL", "LEFT", "DOWN", "RIGHT"]
    ]

    static let PerKeymap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.75, 1, 1, 1, 1],
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.50, 1, 1, 1],
        [2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1],
        [3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1],
        [2, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]

    static let PerKeyNames = [
        ["ESC", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "PRT", "SCR", "BRK", "INS", "DEL", "PGUP", "PGDN"],
        ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BACKSPACE", "NUMLOCK", "/", "*", "-"],
        ["TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\", "7", "8", "9"],
        ["CAPS", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "ENTER", "4", "5", "6", "+"],
        ["SHIFT", "Z", "X", "C", "V", "B", "N", "M", ", ", ".", "/", "SHIFT", "UP", "1", "2", "3"],
        ["CTRL", "FN", "ALT", "SPACEBAR", "\\", "ALT", "WIN", "CTRL", "LEFT", "DOWN", "RIGHT", "0", ".", "ENTER"]
    ]
}
