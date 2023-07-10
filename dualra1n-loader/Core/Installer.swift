//
//  Installer.swift
//  dualra1n-loader
//
//  Created by Leonard on 09.04.23.
//

import Foundation

class Installer: ObservableObject {
    private var isWorking: Bool = false
    private var logger: Logger = Logger.shared
    
    func bootstrap() {
        guard !isWorking else {
            self.logger.addToLog("Installer is busy")
            return
        }
        
        isWorking = true
        
        guard let helper = Bundle.main.path(forAuxiliaryExecutable: "dualra1n-helper"),
              let tsHelper = Bundle.main.path(forAuxiliaryExecutable: "trollstore13helper"),
              let tsTar = Bundle.main.path(forResource: "TrollStore", ofType: "tar"),
              let sileo = Bundle.main.path(forResource: "sileo", ofType: "deb") else {
            self.logger.addToLog("Could not find ressources")
            isWorking = false
            return
        }
        
        let device = JBDevice()
        guard let url = device.getBootstrap().0, let file = device.getBootstrap().1 else {
            self.logger.addToLog("Could not get bootstrap for your device")
            isWorking = false
            return
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let bootstrapURL = documentsURL.appendingPathComponent(file)
        DispatchQueue.global(qos: .utility).async {
            if(!FileManager.default.fileExists(atPath: bootstrapURL.absoluteString.replacingOccurrences(of: "file://", with: ""))) {
                guard self.downloadFile(url: url, file: file) == 0 else {
                    DispatchQueue.main.async {
                        self.logger.addToLog("Failed to download bootstrap")
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                self.logger.addToLog("Extracting bootstrap")
                DispatchQueue.global(qos: .utility).async { [self] in
                    let mountRoot = spawn(command: "/sbin/mount", args: ["-uw", "/"], root: true)
                    let bootstrap = spawn(command: helper, args: ["-i", bootstrapURL.absoluteString.replacingOccurrences(of: "file://", with: "")], root: true)
                    spawn(command: "/usr/bin/chmod", args: ["4755", "/usr/bin/sudo"], root: true)
                    spawn(command: "/usr/bin/chown", args: ["root:wheel", "/usr/bin/sudo"], root: true)
                    DispatchQueue.main.async {
                        self.logger.vLog(mountRoot.1 + bootstrap.1)
                        if bootstrap.0 != 0 {
                            self.logger.addToLog("Failed to extract bootstrap")
                            self.isWorking = false
                            return
                        }
                        self.logger.addToLog("Preparing bootstrap")
                        DispatchQueue.global(qos: .utility).async {
                            let prepareBootstrap = spawn(command: "/usr/bin/sh", args: ["/prep_bootstrap.sh"], root: true)
                            let firmware = spawn(command: "/usr/libexec/firmware", args: [], root: true)
                            DispatchQueue.main.async {
                                self.logger.vLog(prepareBootstrap.1)
                                if prepareBootstrap.0 != 0 {
                                    self.isWorking = false
                                    return
                                }
                                self.logger.addToLog("Installing Sileo")
                                DispatchQueue.global(qos: .utility).async {
                                    let installLS = spawn(command: "/usr/bin/dpkg", args: ["-i", sileo], root: true)
                                    let installSources = spawn(command: helper, args: ["-a"], root: true)
                                    DispatchQueue.main.async {
                                        self.logger.vLog(installLS.1 + installSources.1)
                                        if installLS.0 != 0 || installSources.0 != 0 {
                                            self.logger.addToLog("Failed to install dependencies")
                                            self.isWorking = false
                                            return
                                        }
                                        self.logger.addToLog("UICache Sileo")
                                        DispatchQueue.global(qos: .utility).async {
                                            let sileo = spawn(command: "/usr/bin/uicache", args: ["-p", "/Applications/Sileo.app"], root: true)
                                            var uicache = ""
                                            if device.isIpad && device.iosVersion < 14.0 {
                                                uicache.append(spawn(command: tsHelper, args: ["install-trollstore", tsTar], root: true).1)
                                                uicache.append(spawn(command: tsHelper, args: ["uninstall-trollstore"], root: true).1)
                                            }
                                            if device.iosVersion <= 13.7 { // ios 14 doesn't need deepsleep fix at all but ios 13 it must have it 
                                                Tools().installDeepsleepFix()
                                            }
                                        
                                            DispatchQueue.main.async {
                                                self.logger.vLog(sileo.1 + uicache)
                                                if sileo.0 != 0 {
                                                    self.logger.addToLog("Failed to run uicache")
                                                    self.isWorking = false
                                                    return
                                                }
                                                self.logger.addToLog("Successfully installed Procursus and Sileo")
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
    
    func downloadFile(url: URL, file: String) -> Int {
        self.logger.addToLog("Downloading \(file)")
        var result = -1
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(file)
        self.logger.vLog("Downloading from \(url.absoluteString) to \(fileURL.absoluteString)")
        let semaphore = DispatchSemaphore(value: 0)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.downloadTask(with: url) { tempLocalUrl, response, error in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: fileURL)
                    self.logger.vLog("Downloaded \(file)")
                    result = 0
                    semaphore.signal()
                } catch (let writeError) {
                    self.logger.addToLog("Could not copy file to disk: \(writeError)")
                    result = 2
                }
            } else {
                self.logger.addToLog("Could not download file: \(error?.localizedDescription ?? "Unknown error")")
                result = 1
            }
        }
        task.resume()
        semaphore.wait()
        return result
    }
}
