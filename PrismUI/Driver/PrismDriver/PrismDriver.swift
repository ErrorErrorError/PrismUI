//
//  PrismController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//
// From https://github.com/Sherlouk/Codedeck/blob/master/Sources/HIDSwift/HIDDeviceMonitor.swift

import Cocoa
import IOKit.hid

public class PrismDriver: NSObject {

    // MARK: Public

    public static let shared = PrismDriver()
    public var currentDevice: PrismDevice?
    internal var models = PrismDeviceModel.allCases.map({ $0.productInformation() })
    public var devices = NSMutableArray()

    private override init() {
        super.init()
        monitoringThread = Thread(target: self, selector: #selector(start), object: nil)
        monitoringThread?.start()
    }

    @objc func start() {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        manager.setDeviceMatchingMultiple(products: models)
        manager.scheduleWithRunLoop(with: CFRunLoopGetCurrent())
        manager.open()

        let matchingCallback: IOHIDDeviceCallback = { inContext, _, _, device in
            let this = unsafeBitCast(inContext, to: PrismDriver.self)
            this.deviceAdded(rawDevice: device)
        }

        let removalCallback: IOHIDDeviceCallback = { inContext, _, _, device in
            let this = unsafeBitCast(inContext, to: PrismDriver.self)
            this.deviceRemoved(rawDevice: device)
        }

        let context = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        manager.registerDeviceMatchingCallback(matchingCallback, context: context)
        manager.registerDeviceRemovalCallback(removalCallback, context: context)

        RunLoop.current.run()
    }

    func stop() {
        monitoringThread?.cancel()
        monitoringThread = nil
    }

    // MARK: Private

    private var monitoringThread: Thread?

    private func deviceAdded(rawDevice: IOHIDDevice) {
        do {
            var prismDevice = try PrismDevice(device: rawDevice)
            if prismDevice.isKeyboardDevice {
                prismDevice = try PrismKeyboardDevice(device: rawDevice)
            }
            self.devices.add(prismDevice)
            Log.debug("Added device: \(prismDevice)")
            NotificationCenter.default.post(name: .prismDeviceAdded, object: prismDevice)
        } catch {
            Log.error("\(error)")
        }
    }

    private func deviceRemoved(rawDevice: IOHIDDevice) {
        do {
            let prismDevice = try PrismDevice(device: rawDevice)
            let deviceInArray = devices.compactMap { $0 as? PrismDevice }.first { device -> Bool in
                prismDevice.identification == device.identification
            }
            if let deviceInArray = deviceInArray {
                self.devices.remove(deviceInArray)
                Log.debug("Removed device: \(deviceInArray)")
                NotificationCenter.default.post(name: .prismDeviceRemoved, object: deviceInArray)
            }
        } catch {
            Log.error("\(error)")
        }
    }

    deinit {
        stop()
    }
}

extension Notification.Name {
    public static let prismDeviceAdded = Notification.Name(rawValue: "prismDeviceAdded")
    public static let prismDeviceRemoved = Notification.Name(rawValue: "prismDeviceRemoved")
}
