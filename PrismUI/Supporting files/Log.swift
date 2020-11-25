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
    static func debug(_ message: String,
                      fileName: String = #file,
                      functionName: String = #function,
                      lineNumber: Int = #line) {
        os_log("%{public}@", log: .app, type: .info, "\((fileName as NSString).lastPathComponent) - " +
                                                     "\(functionName) at line \(lineNumber): \(message)")
    }

    static func error(_ message: String,
                      fileName: String = #file,
                      functionName: String = #function,
                      lineNumber: Int = #line) {
        os_log("%{public}@", log: .app, type: .error, "\((fileName as NSString).lastPathComponent) - " +
                                                      "\(functionName) at line \(lineNumber): \(message)")
    }
}

extension OSLog {
    static let app = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "PrismUI")
}
