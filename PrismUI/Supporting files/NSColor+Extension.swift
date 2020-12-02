//
//  NSColor+Extension.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/16/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

extension NSColor {

    var prismHSB: PrismHSB {
        return PrismHSB(hue: self.hueComponent,
                       saturation: self.saturationComponent,
                       brightness: self.brightnessComponent,
                       alpha: self.alphaComponent)
    }

    var prismRGB: PrismRGB {
        return PrismRGB(red: self.redComponent,
                        green: self.greenComponent,
                        blue: self.blueComponent,
                        alpha: self.alphaComponent)
    }

    var isDarkColor: Bool {
        var hue, saturation, value, alpha: CGFloat
        (hue, saturation, value, alpha) = (0, 0, 0, 0)
        self.getHue(&hue, saturation: &saturation, brightness: &value, alpha: &alpha)
        return value < 0.25
    }

    func colorMergeOpacity(base: NSColor, opacity: CGFloat) -> NSColor {
        let bgR = base.redComponent * (1.0 - opacity)
        let bgG = base.greenComponent * (1.0 - opacity)
        let bgB = base.blueComponent * (1.0 - opacity)

        let fgR = self.redComponent * opacity
        let fgG = self.greenComponent * opacity
        let fgB = self.blueComponent * opacity

        return NSColor(calibratedRed: (fgR + bgR), green: (fgG + bgG), blue: (fgB + bgB), alpha: 1.0)
    }
}
