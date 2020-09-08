//
//  PerKeyViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyboardViewController: BaseViewController {

    override func loadView() {
        view = DragSelectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        (self.view as? NSVisualEffectView)?.material = .contentBackground
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard let prismDevice = PrismDriver.shared.currentDevice,
            prismDevice.isKeyboardDevice else { return }
        if prismDevice.model != .threeRegion {
            setupPerKeyLayout(model: prismDevice.model)
        } else {
            return
        }
    }
}

extension KeyboardViewController: ColorViewDelegate {
    func didSelect(_ sender: ColorView) {
        PrismKeyboard.keysSelected.add(sender)
    }

    func didDeselect(_ sender: ColorView) {
        PrismKeyboard.keysSelected.remove(sender)
    }
}
