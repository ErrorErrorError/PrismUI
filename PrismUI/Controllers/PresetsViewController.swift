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
        let image = NSImage(named: NSImage.addTemplateName)!
        let view = NSButton(image: image, target: self, action: nil)
        view.isBordered = false
        return view
    }()

     override func viewDidLoad() {
        super.viewDidLoad()
        (self.view as? NSVisualEffectView)?.material = .sidebar

        outlineView.addTableColumn(column)
        outlineView.outlineTableColumn = column
        outlineView.delegate = self

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
        setupDevicePresets()
    }

    private func setupDevicePresets() {
        content.removeAll()

        // MARK: Setup default presets
        guard let currentDevice = PrismDriver.shared.currentDevice, currentDevice.model != .unknown else { return }
        let deviceModel = currentDevice.model

        // MARK: Check to see if there is default presets for the selected model
        if let resourceDir = Bundle.main.urls(forResourcesWithExtension: "bin", subdirectory: nil)?
            .filter({ $0.lastPathComponent.contains("\(deviceModel).bin") }) {
            let defaultPresets = PrismPreset(title: "Default Presets", type: .defaultPreset)
            for url in resourceDir {
                if let presetName = url.lastPathComponent.components(separatedBy: "-").first {
                    let preset = PrismPreset(title: presetName, type: .defaultPreset)
                    preset.url = url
                    defaultPresets.children.append(preset)
                }
            }

            content.append(contentsOf: [defaultPresets])
        }

        // MARK: Setup custom presets

        let fileManager = FileManager.default
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let prismUIDir = appSupportURL.appendingPathComponent("PrismUI")
            if !fileManager.fileExists(atPath: prismUIDir.absoluteString) {
                do {
                    try fileManager.createDirectory(at: prismUIDir, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    Log.error("\(error)")
                }
            }

            let presetsFolder = prismUIDir.appendingPathComponent("presets-\(deviceModel)")

            if !fileManager.fileExists(atPath: presetsFolder.absoluteString) {
                do {
                    try fileManager.createDirectory(at: presetsFolder,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    Log.error("\(error)")
                }
            }

            // MARK: Get custom presets if any
            do {
                var customPresetsURL = try fileManager.contentsOfDirectory(at: presetsFolder,
                                                                                  includingPropertiesForKeys: .none,
                                                                                  options: .skipsHiddenFiles)
                try customPresetsURL.sort {
                    let values1 = try $0.resourceValues(forKeys: [.creationDateKey])
                    let values2 = try $1.resourceValues(forKeys: [.creationDateKey])

                    if let date1 = values1.allValues.first?.value as? Date,
                        let date2 = values2.allValues.first?.value as? Date {
                        return date1.compare(date2) == (.orderedAscending)
                    }
                    return true
                }

                let customPresets = PrismPreset(title: "Custom Presets", type: .customPreset)
                for url in customPresetsURL {
                    if let presetName = url.lastPathComponent.components(separatedBy: "-").first {
                        let preset = PrismPreset(title: presetName, type: .customPreset)
                        preset.url = url
                        customPresets.children.append(preset)
                    }
                }

                content.append(contentsOf: [customPresets])
            } catch {
                Log.error("\(error)")
            }
        } else {
            Log.error("Could not get application support url.")
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
        textField.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: cell.heightAnchor).isActive = true
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

    @objc func savePreset(_ sender: NSButton) {
    }

    @objc func removePreset(_ sender: NSMenuItem) {
        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? NSTreeNode else { return }
        guard let preset = item.representedObject as? PrismPreset else { return }
        print(preset)
    }
}

// MARK: Notification broadcast

extension Notification.Name {
    public static let prismDeviceUpdateFromPreset = Notification.Name(rawValue: "prismDeviceUpdateFromPreset")
}
