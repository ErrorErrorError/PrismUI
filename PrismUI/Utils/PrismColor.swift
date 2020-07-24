//
//  ColorUtil.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/21/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

public class PrismHSB: NSObject, NSCopying {

    // All var range are from 0..1
    public var hue: CGFloat
    public var saturation: CGFloat
    public var brightness: CGFloat
    public var alpha: CGFloat

    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }

    public var nsColor: NSColor {
        get {
            return NSColor(hue: self.hue,
                           saturation: self.saturation,
                           brightness: self.brightness,
                           alpha: self.alpha)
        }
        set(newColor) {
            self.hue = newColor.hueComponent
            self.saturation = newColor.saturationComponent
            self.brightness = newColor.brightnessComponent
            self.alpha = newColor.alphaComponent
        }
    }

    func toRGB() -> PrismRGB {
        if saturation == 0 { return PrismRGB(red: brightness, green: brightness, blue: brightness) }

        let angle = (hue * 360 >= 360 ? 0 : hue * 360)
        let sector = angle / 60 // Sector
        let roundedSector = floor(sector)
        let factorial = sector - roundedSector // Factorial part of h

        let point = brightness * (1 - saturation)
        let queue = brightness * (1 - (saturation * factorial))
        let testy = brightness * (1 - (saturation * (1 - factorial)))

        switch roundedSector {
        case 0:
            return PrismRGB(red: brightness, green: testy, blue: point, alpha: alpha)
        case 1:
            return PrismRGB(red: queue, green: brightness, blue: point, alpha: alpha)
        case 2:
            return PrismRGB(red: point, green: brightness, blue: testy, alpha: alpha)
        case 3:
            return PrismRGB(red: point, green: queue, blue: brightness, alpha: alpha)
        case 4:
            return PrismRGB(red: testy, green: point, blue: brightness, alpha: alpha)
        default:
            return PrismRGB(red: brightness, green: point, blue: queue, alpha: alpha)
        }
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = PrismHSB(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        return copy
    }
}

public class PrismRGB: NSObject {
    // Percent
    let red: CGFloat // [0,1]
    let green: CGFloat // [0,1]
    let blue: CGFloat // [0,1]
    let alpha: CGFloat

    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    func toHSV() -> PrismHSB {
        let hsb: PrismHSB = PrismHSB(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.0)

        let maxV = max(red, max(green, blue))
        let minV = min(red, min(green, blue))
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        let brightness = maxV

        let delta: CGFloat = maxV - minV

        saturation = maxV == 0 ? 0 : delta / minV

        if maxV == minV {
            hue = 0
        } else {
            if maxV == red {
                hue = (green - blue) / delta + (green < blue ? 6 : 0)
            } else if maxV == green {
                hue = (blue - red) / delta + 2
            } else if maxV == blue {
                hue = (red - green) / delta + 4
            }

            hue /= 6
        }

        hsb.hue = hue
        hsb.saturation = saturation
        hsb.brightness = brightness
        hsb.alpha = alpha
        return hsb
    }
}
