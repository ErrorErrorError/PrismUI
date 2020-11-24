//
//  PresetsManager.swift
//  PrismUI
//
//  Created by Erik Bautista on 11/22/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

final class PresetsManager {

    enum PrismPresetError: Error {
        case couldNotCreateDir
        case couldNotCreateFile
        case appSupportNotFound
    }

    static let fileManager = FileManager.default

    class func fetchAllDefaultPresets(with deviceModel: PrismDeviceModel) -> PrismPreset? {
        var defaultPresets: PrismPreset?
        if let resourceDir = Bundle.main.urls(forResourcesWithExtension: "bin", subdirectory: nil)?
            .filter({ $0.lastPathComponent.contains("\(deviceModel).bin") }) {
            defaultPresets = PrismPreset(title: "Default Presets", type: .defaultPreset)
            for url in resourceDir {
                if let presetName = url.lastPathComponent.components(separatedBy: "-").first {
                    let preset = PrismPreset(title: presetName, type: .defaultPreset)
                    preset.url = url
                    defaultPresets?.children.append(preset)
                }
            }
        }

        return defaultPresets
    }

    class func fetchAllCustomPresets(with deviceModel: PrismDeviceModel) -> PrismPreset? {
        var customPresets: PrismPreset?
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

                customPresets = PrismPreset(title: "Custom Presets", type: .customPreset)
                for url in customPresetsURL {
                    if let presetName = url.lastPathComponent.components(separatedBy: ".bin").first {
                        let preset = PrismPreset(title: presetName, type: .customPreset)
                        preset.url = url
                        customPresets?.children.append(preset)
                    }
                }

                return customPresets
            } catch {
                Log.error("\(error)")
            }
        } else {
            Log.error("Could not find app support folder for PrismUI.")
        }

        return customPresets
    }

    class func createCustomPresetFile(data: Data, deviceModel: PrismDeviceModel, name: String) throws -> URL {
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let prismUIDir = appSupportURL.appendingPathComponent("PrismUI")
            if !fileManager.fileExists(atPath: prismUIDir.absoluteString) {
                do {
                    try fileManager.createDirectory(at: prismUIDir, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    Log.error("Could not create directory for PrismUI AppSupport: \(error)")
                    throw PrismPresetError.couldNotCreateDir
                }
            }

            let presetsFolder = prismUIDir.appendingPathComponent("presets-\(deviceModel)")

            if !fileManager.fileExists(atPath: presetsFolder.absoluteString) {
                do {
                    try fileManager.createDirectory(at: presetsFolder,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    Log.error("Could not create custom preset dir for \(deviceModel): \(error)")
                    throw PrismPresetError.couldNotCreateDir
                }
            }

            // MARK: Create file and add the oreset

            let newPresetURL = presetsFolder.appendingPathComponent("\(name).bin")
            do {
                try data.write(to: newPresetURL)
            } catch {
                Log.error("There was an error trying to write for file \(name): \(error)")
                throw PrismPresetError.couldNotCreateFile
            }
            return newPresetURL
        } else {
            Log.error("Could not find app support folder for PrismUI.")
            throw PrismPresetError.appSupportNotFound
        }
    }
}
