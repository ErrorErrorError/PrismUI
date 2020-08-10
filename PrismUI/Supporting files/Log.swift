//
//  Log.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/25/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import OSLog
import PrismDriver

final class Log {
    static func debug(_ message: String) {
        os_log("%{public}@", log: .prismUI, type: .info, message)
        ////// TESTING COMMITTTTT
        //// SECOND COMMITTTTTT
    }

    static func error(_ message: String) {
        os_log("%{public}@", log: .prismUI, type: .error, message)
    }
}

extension OSLog {
    static let prismUI = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "PrismUI")
    static let prismDriver = OSLog(subsystem: Bundle(for: PrismDriver.self).bundleIdentifier!, category: "PrismDriver")
}
