//
//  dualra1n-controller.swift
//  dualra1n
//
//  Created by Uckermark on 16.10.22.
//
// Some of this code belongs to Amy While and is from https://github.com/elihwyma/Pogo

import Foundation
import SwiftUI


public class Actions: ObservableObject {
    private var isWorking: Bool
    @Published var log: String
    @Published var verbose: Bool

    init() {
        isWorking = false
        log = ""
        verbose = false
    }
    
    func Install() {
        guard !isWorking else {
            addToLog(msg: "[*] Installer is busy")
            return
        }
        isWorking = true
        
        guard let tar = Bundle.main.path(forResource: "bootstrap", ofType: "tar") else {
            addToLog(msg: "[*] Could not find Bootstrap")
            isWorking = false
            return
        }
         
        guard let helper = Bundle.main.path(forAuxiliaryExecutable: "dualra1n-loaderHelper") else {
            addToLog(msg: "[*] Could not find helper")
            isWorking = false
            return
        }
         
        guard let deb = Bundle.main.path(forResource: "sileo", ofType: ".deb") else {
            addToLog(msg: "[*] Could not find Sileo deb")
            isWorking = false
            return
        }
        
        guard let substitute = Bundle.main.path(forResource: "substitute", ofType: ".deb") else {
            addToLog(msg: "[*] Could not find Substitute deb")
            isWorking = false
            return
        }
        
        addToLog(msg: "[*] Installing Bootstrap")
        DispatchQueue.global(qos: .utility).async { [self] in
            let ret1 = spawn(command: "/sbin/mount", args: ["-uw", "/"], root: true).1
            let ret = spawn(command: helper, args: ["-i", tar], root: true)
            DispatchQueue.main.async {
                self.vLog(msg: ret1)
                if ret.0 != 0 {
                    self.addToLog(msg: "[*] Error Installing Bootstrap")
                    self.isWorking = false
                    return
                }
                self.addToLog(msg: "[*] Preparing Bootstrap")
                DispatchQueue.global(qos: .utility).async {
                    let ret = spawn(command: "/usr/bin/sh", args: ["/prep_bootstrap.sh"], root: true)
                    DispatchQueue.main.async {
                        self.vLog(msg: ret.1)
                        if ret.0 != 0 {
                            self.isWorking = false
                            return
                        }
                        self.addToLog(msg: "[*] Installing Sileo")
                        DispatchQueue.global(qos: .utility).async {
                            let ret = spawn(command: "/usr/bin/dpkg", args: ["-i", deb], root: true)
                            let ret1 = spawn(command: "/usr/bin/dpkg", args: ["-i", substitute], root: true)
                            DispatchQueue.main.async {
                                self.vLog(msg: ret.1 + ret1.1)
                                if ret.0 != 0 || ret1.0 != 0 {
                                    self.addToLog(msg: "[*] Failed to install debs")
                                    self.isWorking = false
                                    return
                                }
                                self.addToLog(msg: "[*] UICache Sileo")
                                DispatchQueue.global(qos: .utility).async {
                                    let ret = spawn(command: "/usr/bin/uicache", args: ["-p", "/Applications/Sileo.app"], root: true)
                                    DispatchQueue.main.async {
                                        self.vLog(msg: ret.1)
                                        if ret.0 != 0 {
                                            self.addToLog(msg: "[*] Failed to run uicache")
                                            self.isWorking = false
                                            return
                                        }
                                        self.addToLog(msg: "[*] Successfully installed Procursus and Sileo")
                                        self.isWorking = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func runUiCache() {
        guard isJailbroken() else{
            addToLog(msg: "[*] Could not find Bootstrap. Are you jailbroken?")
            return
        }
        // for every .app file in /Applications, run uicache -p
        let fm = FileManager.default
        let apps = try? fm.contentsOfDirectory(atPath: "/Applications")
        if apps == nil {
            self.addToLog(msg: "[*] Could not access Applications")
            return
        }
        let excludeApps = ["Sidecar.app", "Xcode Previews.app"]
        for app in apps ?? [] {
            if app.hasSuffix(".app") && excludeApps.contains(app) {
                let ret = spawn(command: "/usr/bin/uicache", args: ["-p", "/Applications/\(app)"], root: true)
                self.vLog(msg: ret.1)
                self.addToLog(msg: "[*] App \(app) refreshed")
                if ret.0 != 0 {
                    self.addToLog(msg: "[*] failed to rebuild IconCache (\(ret))")
                    return
                }
            }
        }
        self.addToLog(msg: "[*] Rebuilt Icon Cache")
    }

    func remountPreboot() {
        let ret = spawn(command: "/sbin/mount", args: ["-uw", "/"], root: true)
        vLog(msg: ret.1)
        if ret.0 == 0 {
            addToLog(msg: "[*] Remounted Preboot R/W")
        } else {
            addToLog(msg: "[*] Failed to remount Preboot R/W")
        }
    }
    
    func launchDaemons() {
        guard isJailbroken() else{
            addToLog(msg: "[*] Could not find Bootstrap. Are you jailbroken?")
            return
        }
        let ret = spawn(command: "/bin/launchctl", args: ["bootstrap", "system", "/Library/LaunchDaemons"], root: true)
        vLog(msg: ret.1)
        if ret.0 != 0 && ret.0 != 34048 {
            addToLog(msg: "[*] Failed to launch Daemons")
        } else {
            addToLog(msg: "[*] Launched Daemons")
        }
    }
    
    func respringJB() {
        guard isJailbroken() else{
            addToLog(msg: "[*] Could not find Bootstrap. Are you jailbroken?")
            return
        }
        let ret = spawn(command: "/usr/bin/killall", args: ["-9", "SpringBoard"], root: true)
        vLog(msg: ret.1)
        if ret.0 != 0 {
            addToLog(msg: "[*] Respring failed")
        }
    }
    
    func runTools() {
        guard isJailbroken() else {
            addToLog(msg: "[*] Could not find Bootstrap. Are you jailbroken?")
            return
        }
        runUiCache()
        remountPreboot()
        launchDaemons()
        respringJB()
    }
    
    func addToLog(msg: String) {
        NSLog(msg)
        log = log + "\n" + msg
    }
    
    func vLog(msg: String) {
        if verbose {
            addToLog(msg: msg)
        }
    }

    func isJailbroken() -> Bool {
        if FileManager().fileExists(atPath: "/.procursus_strapped"){
            return true
        } else {
            return false
        }
    }
}
