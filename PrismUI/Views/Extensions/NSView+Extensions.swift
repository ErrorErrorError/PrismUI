//
//  NSView+Extensions.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/25/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//
// from https://github.com/IsaacXen/Demo-Cocoa-Drag-Selection/blob/master/ViewsInFrame/NSView%2BViewsInFrame.swift
import Cocoa

extension NSView {

    enum CaptureOption {
        case any, midPoint, full
    }

    func views(in frameRect: NSRect, options: CaptureOption = .midPoint) -> [NSView] {
        return subviews.filter { view in
            switch options {
            case .any:
                return frameRect.intersects(view.frame)
            case .midPoint:
                return frameRect.contains(CGPoint(x: view.frame.midX,
                                                  y: view.frame.midY))
            case .full:
                return frameRect.contains(view.frame)
            }
        }
    }

    func contain(_ view: NSView, in frameRect: NSRect) -> Bool {
        //        switch options {
        //        case .any:
        return frameRect.intersects(view.frame)
        //        case .midPoint:
        //            return frameRect.contains(NSMakePoint(view.frame.midX, view.frame.midY))
        //        case .full:
        //            return frameRect.contains(view.frame)
    }
}
