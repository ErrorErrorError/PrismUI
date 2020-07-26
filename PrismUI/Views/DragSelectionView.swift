//
//  ContainerDragSelectView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/25/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//
// From https://github.com/IsaacXen/Demo-Cocoa-Drag-Selection/blob/master/ViewsInFrame/ContainerView.swift

import Cocoa

class DragSelectionView: NSVisualEffectView {

    private var selectionLayer: CAShapeLayer?
    private var selectionRect: NSRect? = .zero {
        didSet {
            subviews.forEach { view in
                if let view = view as? ColorView {
                    if let rect = selectionRect {
                        let contains = contain(view, in: rect)
                        if contains != view.isSelected {
                            view.isSelected = contains
                        }
                    }
                }
            }

            needsDisplay = true
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateLayer() {
        super.updateLayer()
        selectionLayer?.removeFromSuperlayer()
        selectionLayer = CAShapeLayer(layer: layer!)
        if let rect = selectionRect {
            let path = CGPath(rect: rect, transform: nil)
            selectionLayer?.lineWidth = 1
            selectionLayer?.path = path
            selectionLayer?.fillColor = NSColor.selectedContentBackgroundColor
                .withAlphaComponent(0.2).cgColor
            selectionLayer?.strokeColor = NSColor.selectedContentBackgroundColor.cgColor
        } else {
            selectionLayer?.path = nil
        }

        layer?.addSublayer(selectionLayer!)
    }

    override func viewDidMoveToWindow() {
        let trackingArea = NSTrackingArea(rect: frame,
                                          options: [.activeInActiveApp, .mouseMoved],
                                          owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    private var isMouseDown = false
    private var downPoint: CGPoint? = CGPoint.zero {
        didSet {
            var wasClicked = false
            subviews.forEach { view in
                if let view = view as? ColorView, !wasClicked {
                    if let pointDown = downPoint {
                        wasClicked = view.frame.contains(pointDown)
                    }
                }
            }
            if !wasClicked && downPoint != nil {
                subviews.forEach {
                    if let view = $0 as? ColorView, view.isSelected {
                        view.isSelected = false
                    }
                }
            }
        }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        downPoint = convert(event.locationInWindow, from: nil)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let currentPoint = convert(event.locationInWindow, from: nil)
        selectionRect = frame.rect(from: downPoint!, to: currentPoint)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        selectionRect = nil
        downPoint = nil
    }

}

extension NSRect {
    func rect(from point1: CGPoint, to point2: CGPoint) -> NSRect {
        let xAxis = max(min(point1.x, point2.x), 0)
        let yAxis = max(min(point1.y, point2.y), 0)
        let width = abs(min(max(0, point1.x), self.width) - min(max(0, point2.x), self.width))
        let height = abs(min(max(0, point1.y), self.height) - min(max(0, point2.y), self.height))
        return NSRect(x: xAxis, y: yAxis, width: width, height: height)
    }
}
