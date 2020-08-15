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
    func contain(_ view: NSView, in frameRect: NSRect) -> Bool {
        return frameRect.intersects(view.frame)
    }
}
