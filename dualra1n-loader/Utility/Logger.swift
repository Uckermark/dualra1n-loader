//
//  Logger.swift
//  dualra1n-loader
//
//  Created by Leonard on 09.04.23.
//

import Foundation
import UIKit

class Logger: ObservableObject {
    static let shared = Logger()
    @Published var log: String
    @Published var rawLog: String
    @Published var statusText: String
    @Published var verbose: Bool
    
    private init() {
        self.log = ""
        self.rawLog = ""
        self.statusText = " "
        self.verbose = false
    }
    
    func addToLog(_ msg: String) {
        statusText = msg
        log = log + "\n[*] " + msg
        addToRawLog(msg)
    }
    
    func vLog(_ msg: String) {
        if verbose {
            log = log + "\n" + msg
        }
        addToRawLog(msg)
    }
    
    func addToRawLog(_ msg: String) {
        rawLog = rawLog + "\n" + msg
    }
    
    func copyLog() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = rawLog
        self.addToLog("Copied log to clipboard")
    }
}
