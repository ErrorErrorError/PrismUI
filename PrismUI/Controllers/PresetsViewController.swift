//
//  PresetsViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import Cocoa

class PresetsViewController: BaseViewController {

    let treeController = NSTreeController()
    @objc dynamic var content = [PrismPreset]()

    let column: NSTableColumn = {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column"))
        return column
    }()

    let outlineView: PresetsOutlineView = {
        let view = PresetsOutlineView()
        view.backgroundColor = NSColor.clear
        view.headerView = nil
        view.focusRingType = .none
        return view
    }()

    let scrollView: NSScrollView = {
        let view = NSScrollView()
        view.backgroundColor = NSColor.clear
        view.drawsBackground = false
        return view
    }()

    let addPreset: NSButton = {
        var image = NSImage(named: NSImage.addTemplateName)!
        if #available(OSX 11.0, *) {
            image = NSImage(systemSymbolName: "plus.circle", accessibilityDescription: "add-preset-button")!
        }
        let view = NSButton(image: image, target: self, action: #selector(savePreset(_:)))
        view.title = "New Preset"
        view.imagePosition = .imageLeft
        view.isBordered = false
        return view
    }()

     override func viewDidLoad() {
        super.viewDidLoad()
        (self.view as? NSVisualEffectView)?.material = .sidebar

        outlineView.addTableColumn(column)
        outlineView.outlineTableColumn = column
        outlineView.delegate = self

        addPreset.target = self

        treeController.objectClass = PrismPreset.self
        treeController.childrenKeyPath = "children"
        treeController.countKeyPath = "count"
        treeController.leafKeyPath = "isLeaf"

        treeController.bind(.contentArray,
                            to: self,
                            withKeyPath: "content",
                            options: nil)

        outlineView.bind(.content,
                         to: treeController,
                         withKeyPath: "arrangedObjects",
                         options: nil)

        outlineView.bind(.sortDescriptors,
                         to: treeController,
                         withKeyPath: "sortDescriptors",
                         options: nil)

        view.addSubview(scrollView)
        view.addSubview(addPreset)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addPreset.translatesAutoresizingMaskIntoConstraints = false

        scrollView.documentView = outlineView
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true

        addPreset.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        addPreset.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8).isActive = true
        addPreset.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true

        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(removePreset(_:)), keyEquivalent: ""))
        outlineView.menu = menu

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectedDeviceChanged(_:)),
                                               name: .prismSelectedDeviceChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addNewPresetName(_:)),
                                               name: .prismDeviceSavePresetFile,
                                               object: nil)
    }

    private func setupDevicePresets(device: PrismDevice) {

        content.removeAll()

        // MARK: Setup default presets

        let deviceModel = device.model

        // MARK: Check to see if there is default presets for the selected model

        if let defaultPresets = PresetsManager.fetchAllDefaultPresets(with: deviceModel) {
            content.append(defaultPresets)
        } else {
            Log.debug("There are no default presets for model: \(deviceModel)")
        }

        // MARK: Check to see if there are custom presets.

        if let customPresets = PresetsManager.fetchAllCustomPresets(with: deviceModel) {
            content.append(customPresets)
        } else {
            Log.error("Could not get custom presets for model: \(deviceModel)")
        }
    }
}

extension PresetsViewController: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let node = item as? NSTreeNode else { return nil }
        let cell = NSTableCellView()
        cell.objectValue = node.representedObject

        let textField = NSTextField(labelWithString: "")
        cell.textField = textField
        cell.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        textField.font = NSFont.systemFont(ofSize: 13)

        if !node.isLeaf {
            textField.font = NSFont.systemFont(ofSize: 12)
            textField.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            textField.textColor = NSColor.headerTextColor
        }
        textField.bind(.value, to: cell, withKeyPath: "objectValue.title", options: nil)
        return cell
    }

    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        guard let node = item as? NSTreeNode else { return nil }
        var rowView: NSTableRowView?

        if !node.isLeaf {
            rowView = PresetsTableRowView()
        }
        return rowView
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return (item as? NSTreeNode)?.isLeaf ?? false
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let preset = (outlineView.item(atRow: outlineView.selectedRow) as? NSTreeNode)?
            .representedObject as? PrismPreset else { return }
        Log.debug("Updating device with preset: \(preset.title)")
        NotificationCenter.default.post(name: .prismDeviceUpdateFromPreset, object: preset)
    }
}

// MARK: Actions

extension PresetsViewController {

    @objc func addNewPresetName(_ notification: Notification) {
        guard let tuple = notification.object as? (Int, URL) else { return }
        if PrismDriver.shared.currentDevice?.identification == tuple.0 {
            let presetUrl = tuple.1
            let presetTitle = presetUrl.lastPathComponent.components(separatedBy: ".bin").first
            let newPreset = PrismPreset(title: presetTitle!, type: .customPreset)
            newPreset.url = presetUrl
            DispatchQueue.main.async {
                self.content.last?.children.append(newPreset)
            }
        }
    }

    @objc func selectedDeviceChanged(_ notification: NSNotification) {
        content.removeAll()

        if let device = notification.object as? PrismDevice {
            setupDevicePresets(device: device)
        }
    }

    @objc func savePreset(_ sender: NSButton) {
        NotificationCenter.default.post(name: .prismDeviceSavePreset, object: nil)
    }

    @objc func removePreset(_ sender: NSMenuItem) {
        if outlineView.clickedColumn != -1 {
            if let treeNode = outlineView.item(atRow: outlineView.clickedRow) as? NSTreeNode,
               let parentNode = outlineView.parent(forItem: treeNode) {
                let childIndex = outlineView.childIndex(forItem: treeNode)

                NSAnimationContext.runAnimationGroup({ _ in
                    self.outlineView.removeItems(at: IndexSet(integer: childIndex),
                                            inParent: parentNode,
                                            withAnimation: .effectFade)
                }, completionHandler: {
                    let parentIndex = self.outlineView.childIndex(forItem: parentNode)
                    self.content[parentIndex].children.remove(at: childIndex)
                    if let preset = treeNode.representedObject as? PrismPreset, let url = preset.url {
                        do {
                            try PresetsManager.fileManager.removeItem(at: url)
                        } catch {
                            Log.error("Could not remove \(preset.title) from storage: \(error)")
                        }
                    }
                })
            } else {
                Log.error("Could not parse preset to NSTreeNode.")
            }
        }
    }
}

// MARK: Notification broadcast

extension Notification.Name {
    public static let prismDeviceUpdateFromPreset: Notification.Name = .init(rawValue: "prismDeviceUpdateFromPreset")
    public static let prismDeviceSavePreset: Notification.Name = .init(rawValue: "prismDeviceSavePreset")
    public static let prismDeviceSavePresetFile: Notification.Name = .init(rawValue: "prismDeviceSavePresetFile")
}
