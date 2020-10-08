//
//  OriginEffectView.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/28/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class OriginEffectView: NSView {

    private var crosshairLocation: NSPoint!
    private var crosshairSize: NSSize!
    private var didPointToCrosshair = false
    private var startPoint: NSPoint!

    var typeOfRad: PrismDirection! {
        didSet {
            needsDisplay = true
        }
    }

    var colorArray: [NSColor] = [NSColor.red, NSColor.blue, NSColor.black] {
        didSet {
            needsDisplay = true
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        crosshairLocation = NSPoint(x: frame.width/2, y: frame.height/2)
        crosshairSize = NSSize(width: 20, height: 20)
        typeOfRad = .xyAxis
        wantsLayer = true
        layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        let currentPoint = convert(event.locationInWindow, from: nil)
        let modifiedPoint = NSPoint(x: currentPoint.x + crosshairSize.width/2,
                                    y: currentPoint.y + crosshairSize.height/2)
        let crosshairRect = NSRect(origin: crosshairLocation, size: crosshairSize)
        didPointToCrosshair = crosshairRect.contains(modifiedPoint)
        startPoint = clampBounds(point: currentPoint)
    }

    override func mouseDragged(with event: NSEvent) {
        let currentPoint = convert(event.locationInWindow, from: nil)
        if didPointToCrosshair {
            crosshairLocation = clampBounds(point: currentPoint)
            needsDisplay = true
        }
    }

    private func clampBounds(point: NSPoint) -> NSPoint {
        var newPoint = NSPoint()
        newPoint.x = max(min(point.x, frame.width), 0)
        newPoint.y = max(min(point.y, frame.height), 0)
        return newPoint
    }

    override func mouseUp(with event: NSEvent) {
        let currentPoint = convert(event.locationInWindow, from: nil)
        if (startPoint != nil) {
            if (startPoint != currentPoint) {
//                let getCalcVal = getCalculatedOrigin()
//                delegate?.newValueUpdated(calcVal: getCalcVal)
            }

            startPoint = nil
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        var newColorArray: [NSColor] = []
        var newLocation: [CGFloat] = []

        if (typeOfRad == .xyAxis) {
            for inx in 0..<colorArray.count {
                let index = inx
                let color = colorArray[index]
                var location: CGFloat
                location = CGFloat(inx + 1) / CGFloat(colorArray.count)
                newColorArray.append(color.withAlphaComponent(0.70))
                newLocation.append(location)
            }
            guard let bgGradient = NSGradient(colors: newColorArray, atLocations: newLocation, colorSpace: .genericRGB) else { return }
            let newPointX = OriginEffectView.clamp(value: crosshairLocation!.x, inMin: 0, inMax: frame.width, outMin: -1.0, outMax: 1.0) - 1
            let newPointY = OriginEffectView.clamp(value: crosshairLocation!.y, inMin: 0, inMax: frame.height, outMin: -1.0, outMax: 1.0) - 1
            bgGradient.draw(in: dirtyRect, relativeCenterPosition: NSPoint(x: newPointX, y: newPointY))
        } else if (typeOfRad == .xAxis) {
            for inx in 0..<(colorArray.count*2) {
                let index = (inx < colorArray.count) ? inx : (inx - colorArray.count)
                let color = colorArray[index]
                let newPointX = OriginEffectView.clamp(value: crosshairLocation!.x, inMin: 0, inMax: frame.width, outMin: 0.0, outMax: 1.0)
                var location: CGFloat
                if (inx < colorArray.count) {
                    location = (newPointX/CGFloat(colorArray.count) * CGFloat(inx))
                } else {
                    location = newPointX + (((1.0 - newPointX) / CGFloat(colorArray.count)) * CGFloat(index))
                }
                newColorArray.append(color.withAlphaComponent(0.70))
                newLocation.append(location)
            }

            let bgGradient = NSGradient(colors: newColorArray, atLocations: newLocation, colorSpace: .genericRGB)!
            bgGradient.draw(in: dirtyRect, angle: 0.0)
        } else {
            for inx in 0..<(colorArray.count*2) {
                let index = (inx < colorArray.count) ? inx : (inx - colorArray.count)
                let color = colorArray[index]
                let newPointY = OriginEffectView.clamp(value: crosshairLocation!.y, inMin: 0, inMax: frame.height, outMin: 0.0, outMax: 1.0)
                var location: CGFloat
                if (inx < colorArray.count) {
                    location = (newPointY/CGFloat(colorArray.count) * CGFloat(inx))
                } else {
                    location = newPointY + (((1.0 - newPointY) / CGFloat(colorArray.count)) * CGFloat(index))
                }
                newColorArray.append(color.withAlphaComponent(0.70))
                newLocation.append(location)
            }

            let bgGradient = NSGradient(colors: newColorArray, atLocations: newLocation, colorSpace: .genericRGB)!
            bgGradient.draw(in: dirtyRect, angle: 90)
        }
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        context.addEllipse(in: CGRect(origin: CGPoint(x: crosshairLocation.x-crosshairSize.width/2, y: crosshairLocation.y-crosshairSize.height/2),
                                      size: crosshairSize))
        context.addLines(between: [CGPoint(x: crosshairLocation.x, y: crosshairLocation.y-14),
                                   CGPoint(x: crosshairLocation.x, y: crosshairLocation.y+14)])
        context.addLines(between: [CGPoint(x: crosshairLocation.x-14, y: crosshairLocation.y),
                                   CGPoint(x: crosshairLocation.x+14, y: crosshairLocation.y)])
        context.strokePath()
    }
//
//    // Returns value of the coordinates in respect to SSEngine's calculations
//
//    func getCalculatedOrigin() -> PrismPoint {
//        let flipYAxis = frame.height - crosshairLocation.y
//        let xAxis = UInt16(OriginEffectView.clamp(value: crosshairLocation.x, in_min: 0, inMax: frame.width, outMin: 0, outMax: 0x10c5))
//        let yAxis = UInt16(OriginEffectView.clamp(value: flipYAxis, in_min: 0, inMax: frame.height, outMin: 0, outMax: 0x040d))
//        return PrismPoint(xPoint: xAxis, yPoint: yAxis)
//    }
//
//    func setDefaultView() {
//        crosshairLocation = NSPoint(x: frame.width/2, y: frame.height/2)
//        typeOfRad = .xyAxis
//    }
//
    func setOrigin(origin: PrismPoint) {
        let flipYAxis =  0x040d - origin.yPoint
        let xAxis = OriginEffectView.clamp(value: CGFloat(origin.xPoint), inMin: 0, inMax: 0x10c5, outMin: 0, outMax: frame.width)
        let yAxis = OriginEffectView.clamp(value: CGFloat(flipYAxis), inMin: 0, inMax: 0x040d, outMin: 0, outMax: frame.height)

        crosshairLocation = clampBounds(point: NSPoint(x: xAxis, y: yAxis))
        needsDisplay = true
    }

    public static func clamp(value: CGFloat, inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat) -> CGFloat {
        let tVal = value - inMin
        let vVal = outMax - outMin
        let nVal = (inMax - inMin) + outMin
        return CGFloat((tVal * vVal) / nVal)
    }
}
