//
//  Tools.swift
//  dualra1n-loader
//
//  Created by Leonard on 09.04.23.
//

import Foundation


class Tools {
    private var logger: Logger = Logger.shared
    
    // For this to work it is required to run "snaputil -c orig-fs /mntX" (X = dualbooted rootdev)
    // before jailbreaking to create the snapshot which is restored in the below function
    func restoreRootFS() {
        let clearVar = spawn(command: "/usr/bin/rm", args: ["-rf", "/var/cache", "/var/lib"], root: true)
        let revertSnapshot = spawn(command: "/usr/bin/snaputil", args: ["-r", "orig-fs", "/"], root: true)
        if revertSnapshot.0 != 0 {
            self.logger.vLog(clearVar.1 + revertSnapshot.1)
            self.logger.addToLog("Failed to restore RootFS")
        } else {
            self.logger.addToLog("Restored RootFS")
            self.logger.addToLog("REBOOT REQUIRED!")
        }
    }
    
    func deleteBootstrap() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let bootstrap = JBDevice().getBootstrap().1 else {
            self.logger.addToLog("Failed to fetch bootstrap URL")
            return
        }
        let bootstrapURL = documentsURL.appendingPathComponent(bootstrap)
        self.logger.vLog("Deleting \(bootstrapURL.absoluteString)")
        do {
            try FileManager.default.removeItem(at: bootstrapURL)
        } catch {
            self.logger.addToLog(error.localizedDescription)
        }
    }
    
    func runUiCache() {
        guard isJailbroken() else{
            self.logger.addToLog("Could not find Bootstrap. Are you jailbroken?")
            return
        }
        // for every .app file in /Applications, run uicache -p
        let fm = FileManager.default
        let apps = try? fm.contentsOfDirectory(atPath: "/Applications")
        if apps == nil {
            self.logger.addToLog("Could not access /Applications")
            return
        }
        let excludeApps = ["Sidecar.app", "Xcode Previews.app", "Feedback Assistant iOS.app"]
        for app in apps ?? [] {
            if app.hasSuffix(".app") && !excludeApps.contains(app) {
                let uicache = spawn(command: "/usr/bin/uicache", args: ["-p", "/Applications/\(app)"], root: true)
                self.logger.vLog(uicache.1)
                self.logger.addToLog("App \(app) refreshed")
                if uicache.0 != 0 {
                    self.logger.addToLog("Failed to rebuild IconCache (\(uicache))")
                    return
                }
            }
        }
        self.logger.addToLog("Rebuilt Icon Cache")
    }

    func remountRW() {
        let mountRoot = spawn(command: "/sbin/mount", args: ["-uw", "/"], root: true)
        self.logger.vLog(mountRoot.1)
        if mountRoot.0 != 0 {
            self.logger.addToLog("Failed to remount R/W")
        } else {
            self.logger.addToLog("Remounted R/W")
        }
    }
    
    func launchDaemons() {
        guard isJailbroken() else{
            self.logger.addToLog("Could not find Bootstrap. Are you jailbroken?")
            return
        }
        let launchDaemons = spawn(command: "/bin/launchctl", args: ["bootstrap", "system", "/Library/LaunchDaemons"], root: true)
        self.logger.vLog(launchDaemons.1)
        if launchDaemons.0 == 0 {
            self.logger.addToLog("Launched daemons")
        } else if launchDaemons.0 == 34048 {
            self.logger.addToLog("Daemons already launched")
        }
    }
    
    func respringJB() {
        guard isJailbroken() else{
            self.logger.addToLog("Could not find Bootstrap. Are you jailbroken?")
            return
        }
        let respring = spawn(command: "/usr/bin/sbreload", args: [], root: true)
        self.logger.vLog(respring.1)
        if respring.0 != 0 {
            self.logger.addToLog("Respring failed")
        }
    }
    
    func enableTweakInjection() {
        guard isJailbroken() else {
            self.logger.addToLog("Could not find bootstrap. Are you jailbroken?")
            return
        }
        if FileManager.default.fileExists(atPath: "/etc/rc.d/libhooker") {
            let libhooker = spawn(command: "/etc/rc.d/libhooker", args: [], root: true)
            if libhooker.0 != 0 {
                self.logger.addToLog("Failed to start libhooker")
                self.logger.vLog(libhooker.1)
            } else {
                self.logger.addToLog("Started libhooker")
            }
        } else if FileManager.default.fileExists(atPath: "/etc/rc.d/substitute-launcher") {
            let substitute = spawn(command: "/etc/rc.d/substitute-launcher", args: [], root: true)
            if substitute.0 != 0 {
                self.logger.addToLog("Failed to start substitute")
                self.logger.vLog(substitute.1)
            } else {
                self.logger.addToLog("Started substitute")
            }
        } else {
            self.logger.addToLog("Could not find tweak injection library")
        }
    }
    
    func reJailbreak() {
        DispatchQueue.global(qos: .utility).async {
            self.runUiCache()
            self.remountRW()
            self.launchDaemons()
            self.enableTweakInjection()
            self.respringJB()
            DispatchQueue.main.async {
                self.logger.addToLog("Done!")
            }
        }
    }
    
    func installSileo() {
        guard isJailbroken() else {
            self.logger.addToLog("Could not find bootstrap. Are you jailbroken?")
            return
        }
        
        guard let sileo = Bundle.main.path(forResource: "sileo", ofType: ".deb") else {
            self.logger.addToLog("Could not find Sileo deb")
            return
        }
        let ret = spawn(command: "/usr/bin/dpkg", args: ["-i", sileo], root: true)
        self.logger.vLog(ret.1)
        if(ret.0 == 0) {
            self.logger.addToLog("Installed Sileo")
        } else {
            self.logger.addToLog("Failed to install Sileo")
        }
    }
    
    func addSource() {
        guard let sources = Bundle.main.path(forResource: "dualra1n", ofType: "sources"),
              let helper = Bundle.main.path(forAuxiliaryExecutable: "dualra1n-helper") else {
            self.logger.addToLog("Could not find ressources")
            return
        }

        let installSources = spawn(command: helper, args: ["-s", sources], root: true)
        if installSources.0 == 0 {
            self.logger.addToLog("Added sources")
        } else {
            self.logger.addToLog("Failed to add sources")
        }
        self.logger.vLog(installSources.1)
    }
    
    func isJailbroken() -> Bool {
        let fm = FileManager.default
        if fm.fileExists(atPath: "/.procursus_strapped") || fm.fileExists(atPath: "/.installed_odyssey") || fm.fileExists(atPath: "/.installed_taurine"){
            return true
        } else {
            return false
        }
    }
}
