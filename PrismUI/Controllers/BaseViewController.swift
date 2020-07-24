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
}
