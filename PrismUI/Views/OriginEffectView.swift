//
//  OriginEffectView.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/28/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class OriginEffectView: NSView {

    private var crosshairLocation: NSPoint = NSPoint()
    private var crosshairSize: NSSize!
    private var didPointToCrosshair = false
    private var startPoint: NSPoint!

    override var isHidden: Bool {
        didSet {
            setOrigin(origin: ModesViewController.waveOrigin)
        }
    }

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
        if startPoint != nil {
            if startPoint != currentPoint {
                let getCalcVal = getCalculatedOrigin()
                ModesViewController.waveOrigin.xPoint = getCalcVal.xPoint
                ModesViewController.waveOrigin.yPoint = getCalcVal.yPoint
                NotificationCenter.default.post(name: .prismUpdateFromNewPoint, object: nil)
            }
            startPoint = nil
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }

        var newColorArray: [CGColor] = []
        var newLocation: [CGFloat] = []

        if typeOfRad == .xyAxis {
            for inx in 0..<colorArray.count {
                let color = colorArray[inx]
                var location: CGFloat
                location = CGFloat(inx + 1) / CGFloat(colorArray.count)
                newColorArray.append(color.withAlphaComponent(0.70).cgColor)
                newLocation.append(location)
            }

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: newColorArray as CFArray,
                                         locations: newLocation) {
                context.drawRadialGradient(gradient,
                                           startCenter: crosshairLocation,
                                           startRadius: 0,
                                           endCenter: crosshairLocation,
                                           endRadius: frame.width / 2,
                                           options: .drawsAfterEndLocation)
            }

        } else if typeOfRad == .xAxis {
            for inx in 0..<(colorArray.count * 2) {
                let index = (inx < colorArray.count) ? inx : (inx - colorArray.count)
                let color = colorArray[index]
                let newPointX = MathUtils.map(value: crosshairLocation.x,
                                              inMin: 0,
                                              inMax: frame.width,
                                              outMin: 0.0,
                                              outMax: 1.0)
                var location: CGFloat
                if inx < colorArray.count {
                    location = (newPointX/CGFloat(colorArray.count) * CGFloat(inx))
                } else {
                    location = newPointX + (((1.0 - newPointX) / CGFloat(colorArray.count)) * CGFloat(index))
                }
                newColorArray.append(color.withAlphaComponent(0.7).cgColor)
                newLocation.append(location)
            }

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace,
                                         colors: newColorArray as CFArray,
                                         locations: newLocation) {
                context.drawLinearGradient(gradient,
                                           start: CGPoint.zero,
                                           end: CGPoint(x: bounds.width, y: 0),
                                           options: .drawsAfterEndLocation)
            }
        } else {
            for inx in 0..<(colorArray.count * 2) {
                let index = (inx < colorArray.count) ? inx : (inx - colorArray.count)
                let color = colorArray[index]
                let newPointY = MathUtils.map(value: crosshairLocation.y,
                                              inMin: 0,
                                              inMax: frame.height,
                                              outMin: 0.0,
                                              outMax: 1.0)
                var location: CGFloat
                if inx < colorArray.count {
                    location = (newPointY/CGFloat(colorArray.count) * CGFloat(inx))
                } else {
                    location = newPointY + (((1.0 - newPointY) / CGFloat(colorArray.count)) * CGFloat(index))
                }
                newColorArray.append(color.withAlphaComponent(0.7).cgColor)
                newLocation.append(location)
            }

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace,
                                         colors: newColorArray as CFArray,
                                         locations: newLocation) {
                context.drawLinearGradient(gradient,
                                           start: CGPoint.zero,
                                           end: CGPoint(x: 0, y: bounds.height),
                                           options: .drawsAfterEndLocation)
            }
        }

        context.setStrokeColor(NSColor.black.cgColor)
        context.addEllipse(in: CGRect(origin: CGPoint(x: crosshairLocation.x-crosshairSize.width/2,
                                                      y: crosshairLocation.y-crosshairSize.height/2),
                                      size: crosshairSize))
        context.addLines(between: [CGPoint(x: crosshairLocation.x, y: crosshairLocation.y-14),
                                   CGPoint(x: crosshairLocation.x, y: crosshairLocation.y+14)])
        context.addLines(between: [CGPoint(x: crosshairLocation.x-14, y: crosshairLocation.y),
                                   CGPoint(x: crosshairLocation.x+14, y: crosshairLocation.y)])
        context.strokePath()
    }

    // Returns value of the coordinates in respect to SSEngine's calculations

    func getCalculatedOrigin() -> PrismPoint {
        let flipYAxis = frame.height - crosshairLocation.y
        let xAxis = UInt16(MathUtils.map(value: crosshairLocation.x, inMin: 0,
                                         inMax: frame.width, outMin: 0, outMax: 0x105c))
        let yAxis = UInt16(MathUtils.map(value: flipYAxis, inMin: 0,
                                         inMax: frame.height, outMin: 0, outMax: 0x040d))
        return PrismPoint(xPoint: xAxis, yPoint: yAxis)
    }

    func setOrigin(origin: PrismPoint) {
        let flipYAxis =  0x040d - origin.yPoint
        let xAxis = MathUtils.map(value: CGFloat(origin.xPoint), inMin: 0,
                                           inMax: 0x105c, outMin: 0, outMax: frame.width)
        let yAxis = MathUtils.map(value: CGFloat(flipYAxis), inMin: 0,
                                           inMax: 0x040d, outMin: 0, outMax: frame.height)

        crosshairLocation = clampBounds(point: NSPoint(x: xAxis, y: yAxis))
        needsDisplay = true
    }
}

extension Notification.Name {
    public static let prismUpdateFromNewPoint: Notification.Name = .init("prismUpdateFromNewPoint")
}
