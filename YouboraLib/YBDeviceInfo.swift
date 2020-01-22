//
//  YBDeviceInfo.swift
//  YouboraLib
//
//  Created by nice on 22/01/2020.
//  Copyright © 2020 NPAW. All rights reserved.
//

import Foundation

#if os(OSX)
import Cocoa
#else
import UIKit
#endif

@objcMembers class YBDeviceInfo: NSObject {
    var deviceModel: String?
    var deviceBrand: String?
    var deviceType: String?
    var deviceName: String?
    var deviceCode: String?
    var deviceOsName: String?
    var deviceOsVersion: String?
    var deviceBrowserName: String?
    var deviceBrowserVersion: String?
    var deviceBrowserType: String?
    var deviceBrowserEngine: String?

    func deviceName(code: String) -> String {
        guard let deviceName = Constants.deviceModels[code] else {
            if code.contains("iPod") { return "iPod Touch" }
            if code.contains("iPad") { return "iPad" }
            if code.contains("iPhone") { return "iPhone" }
            if code.contains("AppleTV") { return "Apple TV" }
            return "Unknown"
        }

        return deviceName
    }

    private func getAppleDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let code = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return self.deviceName(code: code)
    }

    private func getDeviceParameters() -> [String: String] {
        var deviceDict: [String: String] = [:]

        deviceDict["model"] = self.deviceModel != nil ? self.deviceModel! : self.getAppleDeviceModel()

        #if os(OSX)
        deviceDict["osVersion"] = self.deviceOsVersion != nil ? self.deviceOsVersion! : ProcessInfo.processInfo.operatingSystemVersionString
        #else
        deviceDict["osVersion"] = self.deviceOsVersion != nil ? self.deviceOsVersion! : UIDevice.current.systemVersion
        #endif

        deviceDict["brand"] = self.deviceBrand != nil ? self.deviceBrand! : "Apple"
        deviceDict["deviceType"] = self.deviceType
        deviceDict["deviceCode"] = self.deviceCode
        deviceDict["osName"] = self.deviceOsName
        deviceDict["browserName"] = self.deviceBrowserName != nil ? self.deviceBrowserName! : ""
        deviceDict["browserVersion"] = self.deviceBrowserVersion != nil ? self.deviceBrowserVersion! : ""
        deviceDict["browserType"] = self.deviceBrowserType != nil ? self.deviceBrowserType! : ""
        deviceDict["browserVersion"] = self.deviceBrowserVersion != nil ? self.deviceBrowserVersion! : ""
        deviceDict["browserEngine"] = self.deviceBrowserEngine != nil ? self.deviceBrowserEngine! : ""

        return deviceDict
    }

    /**
     * Maps all phone data to a JSON string
     * @returns formatted JSON string
     */
    public func mapToJSONString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.getDeviceParameters(), options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            YBSwiftLog.error("Unable to generate device JSON \(error)")
            return nil
        }
    }

}
