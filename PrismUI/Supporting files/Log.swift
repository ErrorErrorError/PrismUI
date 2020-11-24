//
//  Log.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/25/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import OSLog

final class Log {
    static func debug(_ message: String, functionName: String = #function) {
        os_log("%{public}@", log: .prismUI, type: .info, "\(functionName): \(message)")
    }

    static func error(_ message: String, functionName: String = #function) {
        os_log("%{public}@", log: .prismUI, type: .error, "\(functionName): \(message)")
    }
}

extension OSLog {
    static let prismUI = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "PrismUI")
}
