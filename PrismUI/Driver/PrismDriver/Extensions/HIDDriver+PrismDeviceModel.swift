//
//  HIDDriver+PrismDeviceModel.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/21/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public extension HIDDevice {

    enum Error: Swift.Error, LocalizedError {
        case notPrismDeviceModel

        public var localizedDescription: String {
            switch self {
            case .notPrismDeviceModel: return "Not a supported device"
            }
        }
    }

    func getPrismDeviceModel() throws -> PrismDeviceModel {
        let product = PrismDeviceModel.allCases.first(where: {
            $0.vendorId == self.vendorId &&
                $0.productId == self.productId &&
                $0.versionNumber == self.versionNumber &&
                $0.primaryUsagePage == self.primaryUsagePage
        })

        guard let unwrappedProduct = product else {
            throw Error.notPrismDeviceModel
        }

        return unwrappedProduct
    }

}
