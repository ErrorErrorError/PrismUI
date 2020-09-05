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

    public static let shared = PrismDriver()
    public var currentDevice: PrismDevice?
    private var monitoringThread: Thread?
    internal var models = PrismDeviceModel.allCases.map({ $0.productInformation() })

    public var devices: NSMutableArray = NSMutableArray()

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

    private func deviceAdded(rawDevice: IOHIDDevice) {
        do {
            var prismDevice = try PrismDevice(device: rawDevice)
            if prismDevice.isKeyboardDevice {
                prismDevice = try PrismKeyboard(device: rawDevice)
            }
            if currentDevice == nil {
                currentDevice = prismDevice
            }
            self.devices.add(prismDevice)
            Log.debug("Added \(prismDevice.description)")
        } catch {
            Log.error("\(error)")
        }
    }

    private func deviceRemoved(rawDevice: IOHIDDevice) {
        do {
            var prismDevice = try PrismDevice(device: rawDevice)
            if prismDevice.isKeyboardDevice {
                prismDevice = try PrismKeyboard(device: rawDevice)
            }
            if prismDevice == currentDevice {
                currentDevice = nil
            }
            self.devices.remove(prismDevice)
            Log.debug("Removed \(prismDevice.description)")
        } catch {
            Log.error("\(error)")
        }
    }

    func stop() {
        monitoringThread?.cancel()
        monitoringThread = nil
    }

    deinit {
        stop()
    }
}
