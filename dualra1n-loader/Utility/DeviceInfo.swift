//
//  DeviceInfo.swift
//  dualra1n-loader
//
//  Created by Uckermark on 23.03.23.
//

import Foundation

public class JBDevice {
    let iosVersion: Double
    let isJailbroken: Bool
    let isSupported: Bool
    
    init() {
        self.iosVersion = Double(ProcessInfo.processInfo.operatingSystemVersion.majorVersion) + Double(ProcessInfo.processInfo.operatingSystemVersion.minorVersion) * 0.1
        self.isJailbroken = FileManager().fileExists(atPath: "/.procursus_strapped")
        self.isSupported = (13.0 <= iosVersion && iosVersion <= 15.0)
    }
    
    func getBootstrap() -> (url: URL?, file: String?) {
        if(iosVersion >= 14.0) {
            return (URL(string: "https://uckermark.tk/bootstrap/bootstrap_1500.tar"), "bootstrap_1500.tar")
        }
        else if(iosVersion >= 13.0) {
            return (URL(string: "https://uckermark.tk/bootstrap/bootstrap_1600.tar"), "bootstrap_1600.tar")
        }
        else if(iosVersion >= 12.0) {
            return (URL(string: "https://uckermark.tk/bootstrap/bootstrap_1700.tar"), "bootstrap_1700.tar")
        }
        return (nil, nil)
    }
}
