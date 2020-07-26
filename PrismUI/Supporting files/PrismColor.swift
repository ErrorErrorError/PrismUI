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

    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1.0) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }

    func toRGB() -> PrismRGB {
        if saturation == 0.0 { return PrismRGB(red: brightness, green: brightness, blue: brightness) }

        let angle: CGFloat = (hue * 360.0 >= 360.0 ? 0.0 : hue * 360.0)
        let sector: CGFloat = angle / 60.0 // Sector
        let roundedSector = floor(sector)
        let factorial = sector - roundedSector // Factorial part of h

        let point: CGFloat = brightness * (1.0 - saturation)
        let queue: CGFloat = brightness * (1.0 - (saturation * factorial))
        let testy: CGFloat = brightness * (1.0 - (saturation * (1.0 - factorial)))

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

    var red: CGFloat // [0, 1]
    var green: CGFloat // [0, 1]
    var blue: CGFloat // [0, 1]
    var alpha: CGFloat // [0, 1]

    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    convenience init(red: Int, green: Int, blue: Int, alpha: Int = 255) {
        let rClamped = CGFloat(min(max(red, 0), 255))
        let gClamped = CGFloat(min(max(green, 0), 255))
        let bClamped = CGFloat(min(max(blue, 0), 255))
        let aClamped = CGFloat(min(max(alpha, 0), 255))
        self.init(red: rClamped / 255.0,
                  green: gClamped / 255.0,
                  blue: bClamped / 255.0,
                  alpha: aClamped / 255.0)
    }

    convenience init(hexString: String) {
        let hexString = hexString
        guard let hexInt = Int(hexString, radix: 16) else {
            self.init(red: 1.0, green: 1.0, blue: 1.0)
            return
        }
        self.init(red: CGFloat((hexInt >> 16) & 0xFF) / 255.0,
                  green: CGFloat((hexInt >> 8) & 0xFF) / 255.0,
                  blue: CGFloat((hexInt >> 0) & 0xFF) / 255.0,
                  alpha: 1.0)
    }

    func toHSV() -> PrismHSB {
        let maxV: CGFloat = max(red, green, blue)
        let minV: CGFloat = min(red, green, blue)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0.0
        let brightness: CGFloat = maxV

        let delta: CGFloat = maxV - minV
        guard delta > 0.00001 else { return PrismHSB(hue: 0.0, saturation: 0.0, brightness: maxV) }
        saturation = maxV == 0.0 ? 0.0 : delta / maxV

        if maxV == minV {
            hue = 0.0
        } else {
            if maxV == red {
                hue = (green - blue) / delta + (green < blue ? 6.0 : 0.0)
            } else if maxV == green {
                hue = (blue - red) / delta + 2.0
            } else if maxV == blue {
                hue = (red - green) / delta + 4.0
            }

            hue /= 6.0
        }

        let hsb: PrismHSB = PrismHSB(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.0)
        hsb.hue = hue
        hsb.saturation = saturation
        hsb.brightness = brightness
        hsb.alpha = alpha
        return hsb
    }
}

extension PrismRGB {

    public var nsColor: NSColor {
        get {
            return NSColor(deviceRed: self.red,
                           green: self.green,
                           blue: self.blue,
                           alpha: self.alpha)
        }
        set(newColor) {
            self.red = newColor.redComponent
            self.green = newColor.greenComponent
            self.blue = newColor.blueComponent
            self.alpha = newColor.alphaComponent
        }
    }

}

extension PrismHSB {

    public var nsColor: NSColor {
        get {
            return NSColor(deviceHue: self.hue,
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

}
