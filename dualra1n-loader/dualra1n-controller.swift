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
    @Published var statusText: String
    @Published var prefs: Preferences

    init() {
        prefs = Preferences()
        isWorking = false
        log = ""
        statusText = " "
        verbose = true
    }
    
    func Install() {
        guard !isWorking else {
            addToLog(msg: "Installer is busy")
            return
        }
        
        isWorking = true
        
        guard let helper = Bundle.main.path(forAuxiliaryExecutable: "dualra1n-helper") else {
            addToLog(msg: "Could not find helper")
            isWorking = false
            return
        }
        
        guard let tsHelper = Bundle.main.path(forAuxiliaryExecutable: "trollstore13helper") else {
            addToLog(msg: "Could not find trollstorehelper")
            isWorking = false
            return
        }
        
        guard let tsTar = Bundle.main.path(forResource: "TrollStore", ofType: "tar") else {
            addToLog(msg: "Could not find trollstore tar")
            isWorking = false
            return
        }
        
        guard let sileo = Bundle.main.path(forResource: "sileo", ofType: "deb") else {
            addToLog(msg: "Could not find Sileo deb")
            isWorking = false
            return
        }
        
        guard let libswift = Bundle.main.path(forResource: "libswift", ofType: "deb") else {
            addToLog(msg: " Could not find libswift")
            isWorking = false
            return
        }
        
        guard let sources = Bundle.main.path(forResource: "dualra1n", ofType: "sources") else {
            addToLog(msg: " Could not find sources")
            isWorking = false
            return
        }
        
        let bootstrap = JBDevice().getBootstrap()
        guard let url = bootstrap.0, let file = bootstrap.1 else {
            addToLog(msg: "Could not get bootstrap for your device")
            isWorking = false
            return
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let bootstrapURL = documentsURL.appendingPathComponent(file)
        DispatchQueue.global(qos: .utility).async {
            if(!FileManager().fileExists(atPath: bootstrapURL.absoluteString.replacingOccurrences(of: "file://", with: ""))) {
                self.downloadFile(url: url, file: file)
            }
            DispatchQueue.main.async {
                self.addToLog(msg: "Extracting bootstrap")
                DispatchQueue.global(qos: .utility).async { [self] in
                    let mountRoot = spawn(command: "/sbin/mount", args: ["-uw", "/"], root: true)
                    //let mountPreboot = spawn(command: "/sbin/mount", args: ["-uw", "/private/preboot"], root: true)
                    let bootstrap = spawn(command: helper, args: ["-i", bootstrapURL.absoluteString.replacingOccurrences(of: "file://", with: "")], root: true)
                    spawn(command: "/usr/bin/chmod", args: ["4755", "/usr/bin/sudo"], root: true)
                    spawn(command: "/usr/bin/chown", args: ["root:wheel", "/usr/bin/sudo"], root: true)
                    DispatchQueue.main.async {
                        self.vLog(msg: mountRoot.1 /*+ mountPreboot.1*/ + bootstrap.1)
                        if bootstrap.0 != 0 {
                            self.addToLog(msg: "Failed to extract bootstrap")
                            self.isWorking = false
                            return
                        }
                        self.addToLog(msg: "Preparing bootstrap")
                        DispatchQueue.global(qos: .utility).async {
                            let prepareBootstrap = spawn(command: "/usr/bin/sh", args: ["/prep_bootstrap.sh"], root: true)
                            DispatchQueue.main.async {
                                self.vLog(msg: prepareBootstrap.1)
                                if prepareBootstrap.0 != 0 {
                                    self.isWorking = false
                                    return
                                }
                                self.addToLog(msg: "Installing Sileo")
                                DispatchQueue.global(qos: .utility).async {
                                    let installLS = spawn(command: "/usr/bin/dpkg", args: ["-i", sileo, libswift], root: true)
                                    let installSources = spawn(command: helper, args: ["-s", sources], root: true)
                                    DispatchQueue.main.async {
                                        self.vLog(msg: installLS.1 + installSources.1)
                                        if installLS.0 != 0 || installSources.0 != 0 {
                                            self.addToLog(msg: "Failed to install dependencies")
                                            self.isWorking = false
                                            return
                                        }
                                        self.addToLog(msg: "UICache Sileo")
                                        DispatchQueue.global(qos: .utility).async {
                                            let sileo = spawn(command: "/usr/bin/uicache", args: ["-p", "/Applications/Sileo.app"], root: true)
                                            let installTS = spawn(command: tsHelper, args: ["install-trollstore", tsTar], root: true)
                                            let uninstallTS = spawn(command: tsHelper, args: ["uninstall-trollstore"], root: true)
                                            DispatchQueue.main.async {
                                                self.vLog(msg: sileo.1 + installTS.1 + uninstallTS.1)
                                                if sileo.0 != 0 {
                                                    self.addToLog(msg: "Failed to run uicache")
                                                    self.isWorking = false
                                                    return
                                                }
                                                self.addToLog(msg: "Successfully installed Procursus and Sileo")
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
        }
    }
    
    func deleteBootstrap() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let bootstrap = JBDevice().getBootstrap().1 else {
            addToLog(msg: "Failed to fetch bootstrap URL")
            return
        }
        let bootstrapURL = documentsURL.appendingPathComponent(bootstrap)
        vLog(msg: "Deleting \(bootstrapURL.absoluteString)")
        do {
            try FileManager().removeItem(at: bootstrapURL)
        } catch {
            addToLog(msg: error.localizedDescription)
        }
    }
    
    func runUiCache() {
        guard isJailbroken() else{
            addToLog(msg: "Could not find Bootstrap. Are you jailbroken?")
            return
        }
        // for every .app file in /Applications, run uicache -p
        let fm = FileManager.default
        let apps = try? fm.contentsOfDirectory(atPath: "/Applications")
        if apps == nil {
            self.addToLog(msg: "Could not access /Applications")
            return
        }
        let excludeApps = ["Sidecar.app", "Xcode Previews.app"]
        for app in apps ?? [] {
            if app.hasSuffix(".app") && !excludeApps.contains(app) {
                let ret = spawn(command: "/usr/bin/uicache", args: ["-p", "/Applications/\(app)"], root: true)
                self.vLog(msg: ret.1)
                self.addToLog(msg: "App \(app) refreshed")
                if ret.0 != 0 {
                    self.addToLog(msg: "Failed to rebuild IconCache (\(ret))")
                    return
                }
            }
        }
        self.addToLog(msg: "Rebuilt Icon Cache")
    }

    func remountRW() {
        let ret0 = spawn(command: "/sbin/mount", args: ["-uw", "/"], root: true)
        let ret1 = spawn(command: "/sbin/mount", args: ["-uw", "/private/preboot"], root: true)
        vLog(msg: ret0.1 + ret1.1)
        if ret0.0 == 0 || ret1.0 == 0 {
            addToLog(msg: "Remounted R/W")
        } else {
            addToLog(msg: "Failed to remount R/W")
        }
    }
    
    func launchDaemons() {
        guard isJailbroken() else{
            addToLog(msg: "Could not find Bootstrap. Are you jailbroken?")
            return
        }
        let ret = spawn(command: "/bin/launchctl", args: ["bootstrap", "system", "/Library/LaunchDaemons"], root: true)
        vLog(msg: ret.1)
        if ret.0 == 0 {
            addToLog(msg: "Launched daemons")
        } else if ret.0 == 34048 {
            addToLog(msg: "Daemons already launched")
        }
    }
    
    func respringJB() {
        guard isJailbroken() else{
            addToLog(msg: "Could not find Bootstrap. Are you jailbroken?")
            return
        }
        let ret = spawn(command: "/usr/bin/sbreload", args: [], root: true)
        vLog(msg: ret.1)
        if ret.0 != 0 {
            addToLog(msg: "Respring failed")
        }
    }
    
    func enableTweakInjection() {
        guard isJailbroken() else {
            addToLog(msg: "Could not find bootstrap. Are you jailbroken?")
            return
        }
        if FileManager().fileExists(atPath: "/etc/rc.d/libhooker") {
            let ret = spawn(command: "/etc/rc.d/libhooker", args: [], root: true)
            if ret.0 != 0 {
                addToLog(msg: "Failed to start libhooker")
                vLog(msg: ret.1)
            } else {
                addToLog(msg: "Started libhooker")
            }
        } else if FileManager().fileExists(atPath: "/etc/rc.d/substitute-launcher") {
            let ret = spawn(command: "/etc/rc.d/substitute-launcher", args: [], root: true)
            if ret.0 != 0 {
                addToLog(msg: "Failed to start substitute")
                vLog(msg: ret.1)
            } else {
                addToLog(msg: "Started substitute")
            }
        } else {
            addToLog(msg: "Could not find tweak injection library")
        }
    }
    
    func runTools() {
        runUiCache()
        remountRW()
        launchDaemons()
        enableTweakInjection()
        respringJB()
        addToLog(msg: "Done!")
    }
    
    func installSileo() {
        guard isJailbroken() else {
            addToLog(msg: "Could not find bootstrap. Are you jailbroken?")
            return
        }
        
        guard let sileo = Bundle.main.path(forResource: "sileo", ofType: ".deb") else {
            addToLog(msg: "Could not find Sileo deb")
            return
        }
        let ret = spawn(command: "/usr/bin/dpkg", args: ["-i", sileo], root: true)
        vLog(msg: ret.1)
        if(ret.0 == 0) {
            addToLog(msg: "Installed Sileo")
        } else {
            addToLog(msg: "Failed to install Sileo")
        }
    }
    
    func addSource() {
        guard let sources = Bundle.main.path(forResource: "dualra1n", ofType: "sources") else {
            addToLog(msg: "Could not find sources")
            return
        }
        guard let helper = Bundle.main.path(forAuxiliaryExecutable: "dualra1n-helper") else {
            addToLog(msg: "Could not find helper")
            return
        }
        let ret = spawn(command: helper, args: ["-s", sources], root: true)
        if ret.0 == 0 {
            addToLog(msg: "Added sources")
        } else {
            addToLog(msg: "Failed to add sources")
        }
        vLog(msg: ret.1)
    }
    
    func addToLog(msg: String) {
        statusText = msg
        log = log + "\n[*] " + msg
    }
    
    func vLog(msg: String) {
        if verbose {
            log = log + "\n[v] " + msg
        }
    }
    
    func isJailbroken() -> Bool {
        if FileManager().fileExists(atPath: "/.procursus_strapped") || FileManager().fileExists(atPath: "/.installed_odyssey") || FileManager().fileExists(atPath: "/.installed_taurine"){
            return true
        } else {
            return false
        }
    }
    
    func downloadFile(url: URL, file: String) -> Void {
        addToLog(msg: "Downloading \(file)")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(file)
        vLog(msg: "Downloading from \(url.absoluteString) to \(fileURL.absoluteString)")
        let semaphore = DispatchSemaphore(value: 0)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.downloadTask(with: url) { tempLocalUrl, response, error in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: fileURL)
                    self.addToLog(msg: "Downloaded \(file)")
                    semaphore.signal()
                } catch (let writeError) {
                    self.addToLog(msg: "Could not copy file to disk: \(writeError)")
                }
            } else {
                self.addToLog(msg: "Could not download file: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        task.resume()
        semaphore.wait()
    }
}
