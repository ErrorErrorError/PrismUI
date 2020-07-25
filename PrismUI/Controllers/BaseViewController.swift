//
//  BaseViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

public class BaseViewController: NSViewController {
    public override func loadView() {
      self.view = NSVisualEffectView()
    }

    // removes first responder from any text fields if mouse clicked outside
    override public func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        view.window?.makeFirstResponder(view)
    }
}
