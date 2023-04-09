//
//  DeviceInfo.swift
//  dualra1n-loader
//
//  Created by Uckermark on 23.03.23.
//

import Foundation
import UIKit

public class JBDevice {
    let iosVersion: Double
    let isIpad: Bool
    let isJailbroken: Bool
    let isSupported: Bool
    
    init() {
        self.iosVersion = Double(ProcessInfo.processInfo.operatingSystemVersion.majorVersion) + Double(ProcessInfo.processInfo.operatingSystemVersion.minorVersion) * 0.1
        self.isIpad = UIDevice.current.userInterfaceIdiom == .pad
        self.isJailbroken = FileManager().fileExists(atPath: "/.procursus_strapped")
        self.isSupported = (13.0 <= iosVersion && iosVersion <= 16.0)
    }
    
    func getBootstrap() -> (url: URL?, file: String?) {
        let server = "https://uckermark.github.io/bootstrap/"
        if(iosVersion >= 15.0) {
            return (URL(string: server + "bootstrap_1800.tar"), "bootstrap_1800.tar")
        }
        else if(iosVersion >= 14.0) {
            return (URL(string: server + "bootstrap_1700.tar"), "bootstrap_1700.tar")
        }
        else if(iosVersion >= 13.0) {
            return (URL(string: server + "bootstrap_1600.tar"), "bootstrap_1600.tar")
        }
        else if(iosVersion >= 12.0) {
            return (URL(string: server + "bootstrap_1500.tar"), "bootstrap_1500.tar")
        }
        return (nil, nil)
    }
    
    func getInfoString() -> String {
        let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let gitCommit: String = Bundle.main.infoDictionary?["REVISION"] as? String ?? "unknown"
        var deviceInfo: String = "loader: v\(version) (\(gitCommit))\n"
        var model: String
        if isIpad {
            model = "iPad"
        } else {
            model = "iPhone"
        }
        deviceInfo.append("device: \(model) \(iosVersion)")
        if isJailbroken {
            deviceInfo.append(" jailbroken")
        }
        return deviceInfo
    }
}
