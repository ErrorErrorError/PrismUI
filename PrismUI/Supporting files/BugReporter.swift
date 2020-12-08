//
//  BugReporter.swift
//  HeliPort
//
//  Created by Erik Bautista on 7/26/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

@IBDesignable
class BugReporter: NSObject {

    public class func generateBugReport() {

        // MARK: App log

        let appIdentifier = Bundle.main.bundleIdentifier!
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown"
        let appBuildVer = Bundle.main.infoDictionary?["CFBundleVersion"] ?? "Unknown"
        let appLogCommand = ["show", "--predicate",
                                  "(subsystem == '\(appIdentifier)')", "--info", "--last", "boot"]
        let appLog = Commands.execute(executablePath: .log, args: appLogCommand).0 ?? "No logs for HeliPort"

        let printLoadedDrivers = PrismDriver.shared.devices.compactMap { "\($0)" }

        let currentlySelectedDevice = PrismDriver.shared.currentDevice?.name ?? "No device selected."

        let devicesLog = """
                         Loaded devices:
                            \(printLoadedDrivers.joined(separator: "\n"))

                         Selected devive: \(currentlySelectedDevice)
                         """
        // MARK: Output String

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        let dateRan = "Time ran: \(formatter.string(from: date))"
        let appOutput = """
                        \(appLog)

                        \(devicesLog)

                        \(dateRan)
                        PrismUI Version: \(appVersion) (Build \(appBuildVer))
                        """

        let fileManager = FileManager.default
        guard let desktopUrl = fileManager.urls(for: .desktopDirectory,
                                                 in: .userDomainMask).first else {
            Log.error("Could not get desktop path to generate bug report.")
            return
        }

        let reportDirName = "bugreport_\(UInt16.random(in: UInt16.min...UInt16.max))"
        let reportDirUrl = desktopUrl.appendingPathComponent(reportDirName, isDirectory: true)

        // MARK: Write to files

        do {
            try fileManager.createDirectory(at: reportDirUrl, withIntermediateDirectories: true, attributes: nil)
            let heliPortFile = reportDirUrl.appendingPathComponent("PrismUI_app.log")
            try appOutput.write(to: heliPortFile, atomically: true, encoding: .utf8)
        } catch {
            Log.error("\(error)")
            return
        }

        // MARK: Zip file

        let zipName = reportDirName + ".zip"
        let zipCommand = ["-c", "cd \(desktopUrl.path) && " +
                                "zip -r -X -m \(zipName) \(reportDirName)"]
        let outputExitCode = Commands.execute(executablePath: .shell, args: zipCommand).1
        guard outputExitCode == 0 else {
            Log.error("Could not create zip file")
            return
        }

        // MARK: Select zip file

        NSWorkspace.shared.selectFile("\(desktopUrl.path)/\(zipName)",
                                      inFileViewerRootedAtPath: desktopUrl.path)
    }
}
