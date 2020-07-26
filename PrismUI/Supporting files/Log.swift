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
    static func debug(_ message: String) {
        os_log("%@", log: .default, type: .debug, message)
    }

    static func error(_ message: String) {
        os_log("%@", log: .default, type: .error, message)
    }
}
