//
//  PrismController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//
// From https://github.com/Sherlouk/Codedeck/blob/master/Sources/HIDSwift/HIDDeviceMonitor.swift

import Cocoa
import IOKit.network

class PrismDriver: NSObject {

    static let shared = PrismDriver()

    private var monitoringThread: Thread?
    internal var models = PrismDeviceModel.allCases.map({ $0.productInformation() })
//    private var dispatchQueue: DispatchQueue?

    public var prismDevice: PrismDevice?

    private override init() {
        super.init()
        DispatchQueue.global(qos: .background).async {
            self.start()
        }
//        monitoringThread = Thread(target: self, selector: #selector(start), object: nil)
//        monitoringThread?.start()
    }

    @objc func start() {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        manager.setDeviceMatchingMultiple(products: models)
        manager.scheduleWithRunLoop(with: CFRunLoopGetCurrent())
        manager.open()

        let matchingCallback: IOHIDDeviceCallback = { inContext, _, _, device in
            let this = unsafeBitCast(inContext, to: PrismDriver.self)
            this.rawDeviceAdded(rawDevice: device)
        }

        let removalCallback: IOHIDDeviceCallback = { inContext, _, _, device in
            let this = unsafeBitCast(inContext, to: PrismDriver.self)
            this.rawDeviceRemoved(rawDevice: device)
        }

        let context = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        manager.registerDeviceMatchingCallback(matchingCallback, context: context)
        manager.registerDeviceRemovalCallback(removalCallback, context: context)

        RunLoop.current.run()
    }

    func rawDeviceAdded(rawDevice: IOHIDDevice) {
        do {
            let device = try HIDDevice(device: rawDevice)
            let prismDevice = try PrismDevice(device: device)
            self.prismDevice = prismDevice
        } catch {
            print(error)
        }
    }

    func rawDeviceRemoved(rawDevice: IOHIDDevice) {
        do {
            let device = try HIDDevice(device: rawDevice)
            let prismDevice = try PrismDevice(device: device)
            self.prismDevice = prismDevice == self.prismDevice ? nil : self.prismDevice
        } catch {
            print(error)
        }
    }

//    func stop() {
//        monitoringThread?.cancel()
//        monitoringThread = nil
//    }

//    deinit {
//        stop()
//    }
}
