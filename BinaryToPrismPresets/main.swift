//
//  main.swift
//  BinaryToPrismPresets
//
//  Created by Erik Bautista on 12/3/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import PrismUI

let fileManager = FileManager()
let fileName = CommandLine.arguments[1]
let maxPackageSize = 0x20c

if let url = fileManager.fileExists(atPath: fileName) ? URL(fileURLWithPath: fileName) : nil {
    do {
        let name = url.lastPathComponent
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        if let jsonResult = jsonResult as? [String: AnyObject] {
            for (key, value) in jsonResult {
                if let array = value as? NSArray {
                    if key.contains("chakra") {
                        print("")
                    }
                    createPreset(name: key, values: array, model: name)
                }
            }
        }
    } catch {
        print(error)
    }
}

func createPreset(name: String, values: NSArray, model: String) {
    let valuesStr = values.compactMap { $0 as? String }
    let valuesIntArr = valuesStr.compactMap { str -> [UInt8] in
        var results = [Substring]()
        var startIndex = str.startIndex
        while startIndex < str.endIndex {
            let endIndex = str.index(startIndex, offsetBy: 2, limitedBy: str.endIndex) ?? str.endIndex
            results.append(str[startIndex..<endIndex])
            startIndex = endIndex
        }
        return results.compactMap({ UInt8($0, radix: 16)})
    }

    let prismEffects = valuesIntArr.compactMap({ createEffectPreset(values: $0) })
    let prismKeys = valuesIntArr.compactMap({ createPrismKeys(values: $0, effects: prismEffects) }).flatMap { $0 }

    let modelName = String(model.split(separator: ".")[0])

    var url = URL(fileURLWithPath: CommandLine.arguments[1])
    url.deleteLastPathComponent()
    url.appendPathComponent(modelName, isDirectory: true)

    if !fileManager.fileExists(atPath: url.path, isDirectory: nil) {
        print(url.path)
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
            return
        }
    }

    // write preset to a file

    let presetName = name.prefix(1).capitalized + name.dropFirst()
    let presetsPath = url.appendingPathComponent("\(presetName)-\(modelName).bin")

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    if let data = try? encoder.encode(prismKeys) {
        do {
            try data.write(to: presetsPath)
        } catch {
            print(error)
        }
    }
//    print("name: \(name) : \(prismKeys)")
}

func createPrismKeys(values: [UInt8], effects: [PrismEffect]) -> [PrismKey]? {
    guard values.count == maxPackageSize && values.first == 0x0e else { return nil }
    var prismKeyArray = [PrismKey]()
    let region = values[0x2] == 0x13 ? 0x24 : values[0x2]
    for index in 0..<(values.count/12) {
        let indexArray = index * 12 + 2
        let keyCode: UInt8
        if values[indexArray] != 0 {
            keyCode = region
        } else if values[indexArray + 1] != 0 {
            keyCode = values[indexArray + 1]
        } else {
            // if both are 0, then its a null key so skip
            continue
        }

        let mainR = values[indexArray + 2]
        let mainG = values[indexArray + 3]
        let mainB = values[indexArray + 4]
        let activeR = values[indexArray + 5]
        let activeG = values[indexArray + 6]
        let activeB = values[indexArray + 7]

        let duration = (UInt16(values[indexArray + 9]) << 8) | UInt16(values[indexArray + 8])

        let effectId = values[indexArray + 10]
        let mode = values[indexArray + 11]

        let mainColor = PrismRGB(red: mainR, green: mainG, blue: mainB)
        let restColor = PrismRGB(red: activeR, green: activeG, blue: activeB)

        let prismKey = PrismKey(region: region, keycode: keyCode)

        if mode != 0x0 {
            if mode == 0x1 {
                prismKey.mode = .steady
            } else if mode == 0x08 {
                prismKey.mode = .reactive
            } else if mode == 0x03 {
                prismKey.mode = .disabled
            }
        } else {
            guard let effect = effects.first(where: { $0.identifier == effectId }) else {
                // If it gets here then the key must be a null key
                continue
            }

            prismKey.mode = .colorShift
            prismKey.effect = effect
        }

        prismKey.main = mainColor
        prismKey.active = restColor
        prismKey.duration = duration

        prismKeyArray.append(prismKey)
    }

    return prismKeyArray
}

func createEffectPreset(values: [UInt8]) -> PrismEffect? {
    guard values.count == maxPackageSize && values.first == 0x0b else { return nil }
    let transitionCount = values[0x96]

    let effectId = values[0x2]

    var beforeColor = PrismRGB(red: (UInt8(values[0x85]) << 4) | (UInt8(values[0x84]) >> 4),
                               green: (UInt8(values[0x87]) << 4) | (UInt8(values[0x86]) >> 4),
                               blue: (UInt8(values[0x89]) << 4) | (UInt8(values[0x88]) >> 4))

    var transitions = [PrismTransition]()

    for index in 0..<transitionCount {
        let indexTransition = Int(index) * 8 + 0x2
        let duration = (UInt16(values[indexTransition + 0x7]) << 8) | UInt16(values[indexTransition + 0x06])
        let colorR = values[indexTransition + 0x02]
        let colorG = values[indexTransition + 0x03]
        let colorB = values[indexTransition + 0x04]

        let delta = PrismRGB(red: colorR, green: colorG, blue: colorB)

        let transition = PrismTransition(color: beforeColor, duration: duration)
        transitions.append(transition)

        let targetColor = delta.undoDelta(startColor: beforeColor, duration: duration)
        beforeColor = targetColor
    }

    // Wave

    let xOrigin = (UInt16(values[0x8d]) << 8) | UInt16(values[0x8c])
    let yOrigin = (UInt16(values[0x8f]) << 8) | UInt16(values[0x8e])

    let xDirection = values[0x90]
    let yDirection = values[0x92]

    let pulse = (UInt16(values[0x95]) << 8) | UInt16(values[0x94])

    let control = values[0x9a]

//    let effectLength = (UInt16(values[0x99]) << 8) | UInt16(values[0x98])

    let effect = PrismEffect(identifier: effectId, transitions: transitions)
    if xDirection != 0 || yDirection != 0 {
        effect.waveActive = true
        effect.origin = PrismPoint(xPoint: xOrigin, yPoint: yOrigin)
        if xDirection == 1 && yDirection == 1 {
            effect.direction = .xyAxis
        } else if xDirection == 1 {
            effect.direction = .xAxis
        } else {
            effect.direction = .yAxis
        }
        effect.pulse = pulse
    } else {
        effect.waveActive = false
    }
    effect.control = PrismControl(rawValue: control) ?? .inward
    return effect
}
