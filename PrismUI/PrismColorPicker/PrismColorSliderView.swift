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
    var color: PrismHSB = PrismHSB(hue: 1, saturation: 1, brightness: 1) {
        didSet(oldValue) {
            needsDisplay = true
        }
    }
    private var colorHueImage: CGImage?
    weak var delegate: PrismColorSliderDelegate?

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        selectorRect = NSRect(x: 0, y: 0, width: 26, height: 26)
        self.wantsLayer = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        let width: CGFloat = bounds.size.width
        let height: CGFloat = bounds.size.height

        let xAxis = width/2 - selectorRect.width/2
        let yAxis = color.hue * (height - selectorRect.height)
        selectorRect.origin = NSPoint(x: xAxis, y: yAxis)

        color.nsColor.setFill()
        context.fillEllipse(in: selectorRect)

        NSColor.white.setStroke()
        context.setLineWidth(strokeWidth)
        context.strokeEllipse(in: selectorRect.insetBy(dx: strokeWidth/2, dy: strokeWidth/2))
        context.resetClip()
    }

    private func updateColorFromPoint(point: NSPoint, mouseUp: Bool = false) {
        guard let newColor = color.copy() as? PrismHSB else { return }
        let height = bounds.height - selectorRect.height/2
        let yAxis = min(max(point.y, 0), height)
        let hue = yAxis / height
        newColor.hue = hue
        color = newColor
        delegate?.didHueChanged(newColor: color, mouseUp: mouseUp)
    }

    private var clickedBounds = false
}

extension PrismColorSliderView {
    override func mouseDown(with event: NSEvent) {
            super.mouseDown(with: event)
        guard let localPoint = window?.contentView?.convert(event.locationInWindow, to: self) else {
            print("Could not convert window point to local point")
            return
        }
        if self.selectorRect.contains(localPoint) {
            clickedBounds = true
            updateColorFromPoint(point: localPoint)
        }
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard let localPoint = window?.contentView?.convert(event.locationInWindow, to: self) else {
            print("Could not convert window point to local point")
            return
        }
        if clickedBounds {
                updateColorFromPoint(point: localPoint)
        }
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        guard let localPoint = window?.contentView?.convert(event.locationInWindow, to: self) else {
            print("Could not convert window point to local point")
            return
        }
        if clickedBounds {
            updateColorFromPoint(point: localPoint, mouseUp: true)
            clickedBounds = false
        }
    }
}

internal protocol PrismColorSliderDelegate: AnyObject {
    func didHueChanged(newColor: PrismHSB, mouseUp: Bool)
}
