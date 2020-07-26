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

    // Workaround: `NSColor`'s `brightnessComponent` is sometimes a value in [0-255] instead of in [0-1]
    /// Brightness value scaled between 0 and 1
    var scaledBrightness: CGFloat {
        if brightnessComponent > 1.0 {
            return brightnessComponent/255.0
        } else {
            return brightnessComponent
        }
    }

    // from https://gist.github.com/mbigatti/c6be210a6bbc0ff25972
    func lighterColor(percent: Double) -> NSColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 + percent))
    }

    /**
     Returns a darker color by the provided percentage
     
     :param: darking percent percentage
     :returns: darker UIColor
     */
    func darkerColor(percent: Double) -> NSColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 - percent))
    }

    /**
     Return a modified color using the brightness factor provided
     
     :param: factor brightness factor
     :returns: modified color
     */
    func colorWithBrightnessFactor(factor: CGFloat) -> NSColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return NSColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
    }

}
