//
//  PrismUITests.swift
//  PrismUITests
//
//  Created by Erik Bautista on 12/4/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import XCTest
@testable import PrismUI

class PrismUITests: XCTestCase {

    func testForColorDelta33Dur() {
        let red = PrismRGB(red: 255, green: 0, blue: 0)
        let white = PrismRGB(red: 255, green: 255, blue: 255)

        let delta = red.delta(target: white, duration: 0x21)

        XCTAssertTrue(delta.redUInt == 0x00)
        XCTAssertTrue(delta.greenUInt == 0x7b)
        XCTAssertTrue(delta.blueUInt == 0x7b)
    }

    func testForColorDelta94Dur() {
        let red = PrismRGB(red: 255, green: 0, blue: 0)
        let white = PrismRGB(red: 255, green: 255, blue: 255)

        let delta = red.delta(target: white, duration: 0x94)

        XCTAssertTrue(delta.redUInt == 0x00)
        XCTAssertTrue(delta.greenUInt == 0x1b)
        XCTAssertTrue(delta.blueUInt == 0x1b)
    }

    func testForColorUndoDeltaToWhite33Dur() {
        let red = PrismRGB(red: 255, green: 0, blue: 0)
        let delta = PrismRGB(red: 0x00, green: 0x7b, blue: 0x7b)

        let target = delta.undoDelta(startColor: red, duration: 0x21)

        XCTAssertTrue(target.redUInt == 0xFF)
        XCTAssertTrue(target.greenUInt == 0xFF)
        XCTAssertTrue(target.blueUInt == 0xFF)
    }

    // Undoing delta is a bit tricky since it looses precision from float to uint8

    func testForColorUndoDelta94Dur() {
        let red = PrismRGB(red: 255, green: 0, blue: 0)
        let delta = PrismRGB(red: 0x00, green: 0x1b, blue: 0x1b)

        let target = delta.undoDelta(startColor: red, duration: 0x94)

//        print("Test: \(target.redUInt) : \(target.greenUInt) : \(target.blueUInt) ")
        XCTAssertTrue(target.redUInt == 0xFF)
        XCTAssertTrue(target.greenUInt == 0xFF)
        XCTAssertTrue(target.blueUInt == 0xFF)

    }

}
