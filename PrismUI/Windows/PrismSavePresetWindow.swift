//
//  PrismSavePresetWindow.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/23/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class PrismSavePresetWindow: NSWindow {

    private var view: NSView!

    private let icon: NSImageView = {
        let image = NSImageView(frame: NSRect.zero)
        image.image = #imageLiteral(resourceName: "PrismUI")
        return image
    }()

    private let titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Do you want to save the color effect as a preset?")
        label.font = NSFont.boldSystemFont(ofSize: 13)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let subTitleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Your changes will be lost if you don't save them.")
        label.font = NSFont.systemFont(ofSize: 11)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private var gridView: NSGridView!

    private let presetNameLabel: NSTextField = {
        let text = NSTextField(labelWithString: "Preset Name:")
        return text
    }()

    private let presetName: NSTextField = {
        let text = NSTextField()
        return text
    }()

    private let leftButton: NSButton = {
        let button = NSButton()
        button.title = "Cancel"
        button.action = #selector(buttonClicked(_:))
        button.bezelStyle = .rounded
        button.font = .systemFont(ofSize: 13)
        button.keyEquivalent = String(format: "%c", 0x001b) // esc key
        return button
    }()

    private let rightButton: NSButton = {
        let button = NSButton()
        button.title = "Save"
        button.action = #selector(buttonClicked(_:))
        button.bezelStyle = .rounded
        button.font = .systemFont(ofSize: 13)
        button.keyEquivalent = String(format: "%c", NSCarriageReturnCharacter)
        button.isEnabled = false
        return button
    }()

    convenience init() {
        self.init(contentRect: NSRect(x: 0, y: 0, width: 450, height: 148),
                  styleMask: .titled,
                  backing: .buffered,
                  defer: false)

        isReleasedWhenClosed = true
        level = .floating

        view = NSView(frame: frame)
        contentView = view

        gridView = NSGridView(views: [
            [presetNameLabel, presetName]
        ])
        gridView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        gridView.column(at: 0).xPlacement = .trailing
        gridView.column(at: 0).width = frame.width * 2/6
        gridView.rowAlignment = .lastBaseline

        view.addSubview(icon)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(gridView)
        view.addSubview(leftButton)
        view.addSubview(rightButton)

        setupContraints()
    }

    private func setupContraints() {
        let inset: CGFloat = 20

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        icon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset).isActive = true
        icon.topAnchor.constraint(equalTo: view.topAnchor, constant: inset).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 64).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 64).isActive = true

        titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: inset).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: inset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset).isActive = true

        subTitleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: inset).isActive = true
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14).isActive = true
        subTitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true

        gridView.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12).isActive = true
        gridView.leadingAnchor.constraint(equalTo: icon.leadingAnchor).isActive = true
        gridView.trailingAnchor.constraint(equalTo: subTitleLabel.trailingAnchor).isActive = true

        rightButton.topAnchor.constraint(equalTo: gridView.bottomAnchor, constant: 16).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset).isActive = true
        rightButton.trailingAnchor.constraint(equalTo: gridView.trailingAnchor).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 70).isActive = true

        leftButton.topAnchor.constraint(equalTo: rightButton.topAnchor).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: rightButton.bottomAnchor).isActive = true
        leftButton.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -12).isActive = true
        leftButton.widthAnchor.constraint(equalToConstant: 70).isActive = true

    }
}

extension PrismSavePresetWindow {
    @objc private func buttonClicked(_ sender: NSButton) {
        switch sender.title {
        case .cancel:
            close()
        case .save:
            break
        default:
            Log.error("Unknown button pressed")
        }
    }
}

extension PrismSavePresetWindow: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {

    }
}

// MARK: Localization strings

private extension String {
    static let cancel = "Cancel"
    static let save = "Save"
}
