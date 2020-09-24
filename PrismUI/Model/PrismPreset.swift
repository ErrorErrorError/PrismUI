//
//  Preset.swift
//  PrismUI
//
//  Created by Erik Bautista on 9/22/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class PrismPreset: NSObject {
    @objc var title: String = ""
    var type: PresetType = .defaultPreset
    @objc var url: URL?
    @objc dynamic var children = [PrismPreset]()

    init(title: String = "", type: PresetType = .defaultPreset) {
        self.title = title
        self.type = type
    }
}

enum PresetType: Int, CaseIterable, Codable {
    case defaultPreset
    case customPreset
}

extension PrismPreset {

    var isDirectory: Bool {
        url?.hasDirectoryPath ?? true
    }

    @objc var count: Int {
        children.count
    }

    @objc var isLeaf: Bool {
        children.isEmpty && !isDirectory
    }
}
