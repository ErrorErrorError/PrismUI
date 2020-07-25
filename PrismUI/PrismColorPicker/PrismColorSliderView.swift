//
//  PrismColorSliderView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/22/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

internal class PrismColorSliderView: NSView {

    private let strokeWidth: CGFloat = 3
    private var selectorRect: NSRect!
    private var colorHueImage: CGImage?
    private var clickedBounds = false
    var color: PrismHSB = PrismHSB(hue: 1, saturation: 1, brightness: 1) {
        willSet(newValue) {
            updateSelectorFromColor(newValue)
            needsDisplay = true
        }
    }

    weak var delegate: PrismColorSliderDelegate?

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        selectorRect = NSRect(x: 0, y: 0, width: 26, height: 26)
        self.wantsLayer = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateSelectorFromColor(color)
    }

}

// MARK: Drawing functions
extension PrismColorSliderView {

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        drawHueSlider(context)
        drawSelector(context)
    }

    private func drawHueSlider(_ contextDraw: CGContext) {
        let rect = bounds.insetBy(dx: 4, dy: 0)
        let path = CGPath(roundedRect: rect,
                          cornerWidth: selectorRect.width,
                          cornerHeight: selectorRect.height,
                          transform: nil)
        guard colorHueImage == nil else {
            contextDraw.addPath(path)
            contextDraw.clip()
            contextDraw.draw(colorHueImage!, in: rect)
            return
        }
        let width = Int(bounds.width)
        let height = Int(bounds.height)
        let totalPixels = width * height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let data = malloc(height * bytesPerRow)
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue
        let context = CGContext(data: data,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)
        let buffer = data?.bindMemory(to: UInt32.self, capacity: totalPixels)
        guard buffer != nil else { return }
        for index in 0..<totalPixels {
            let hue: CGFloat = 1 - CGFloat(index / width) / CGFloat(height)
            let hsbColor = PrismHSB(hue: hue, saturation: 1, brightness: 1)
            let rgbColor = hsbColor.toRGB()
            buffer?[index] =
                UInt32(rgbColor.red * 255) << 24 |
                UInt32(rgbColor.green * 255) << 16 |
                UInt32(rgbColor.blue * 255) << 8 | 0x00000000
        }
        colorHueImage = context?.makeImage()
        contextDraw.addPath(path)
        contextDraw.clip()
        contextDraw.draw(colorHueImage!, in: rect)
    }

    private func drawSelector(_ context: CGContext) {
        context.resetClip()
        color.nsColor.setFill()
        context.fillEllipse(in: selectorRect)

        NSColor.white.setStroke()
        context.setLineWidth(strokeWidth)
        context.strokeEllipse(in: selectorRect.insetBy(dx: strokeWidth/2, dy: strokeWidth/2))
        context.resetClip()
    }

}

// MARK: Update functions
extension PrismColorSliderView {

    private func updateColorFromPoint(point: NSPoint, mouseUp: Bool = false) {
        guard let newColor = color.copy() as? PrismHSB else { return }
        let height = bounds.height - selectorRect.height
        let yAxis = min(max(point.y, 0), height)
        let hue = yAxis / height
        newColor.hue = hue
        color = newColor
        delegate?.didHueChanged(newColor: color, mouseUp: mouseUp)
    }

    private func updateSelectorFromColor(_ newColor: PrismHSB) {
        let width: CGFloat = bounds.size.width
        let height: CGFloat = bounds.size.height - selectorRect.height

        let xAxis = width/2 - selectorRect.width/2
        let yAxis = newColor.hue * height
        selectorRect.origin = NSPoint(x: xAxis, y: yAxis)
    }

    private func updateSelectorFromPoint(_ newPoint: CGPoint) {
        let width = bounds.size.width - selectorRect.width
        let height = bounds.size.height - selectorRect.height
        var xAxis = newPoint.x - selectorRect.width/2
        var yAxis = newPoint.y - selectorRect.height/2
        xAxis = min(max(xAxis, 0), width)
        yAxis = min(max(yAxis, 0), height)
        selectorRect.origin = CGPoint(x: xAxis, y: yAxis)
    }

}

extension PrismColorSliderView {

    override func mouseDown(with event: NSEvent) {
            super.mouseDown(with: event)
        guard let newPoint = window?.contentView?.convert(event.locationInWindow, to: self) else {
            print("Could not convert window point to local point")
            return
        }
        if self.selectorRect.contains(newPoint) {
            updateSelectorFromPoint(newPoint)
            updateColorFromPoint(point: selectorRect.origin)
            clickedBounds = true
        }
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard let newPoint = window?.contentView?.convert(event.locationInWindow, to: self) else {
            print("Could not convert window point to local point")
            return
        }

        guard clickedBounds else { return }
        updateSelectorFromPoint(newPoint)
        updateColorFromPoint(point: selectorRect.origin)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if clickedBounds {
            updateColorFromPoint(point: selectorRect.origin, mouseUp: true)
            clickedBounds = false
        }
    }

}

internal protocol PrismColorSliderDelegate: AnyObject {
    func didHueChanged(newColor: PrismHSB, mouseUp: Bool)
}
