//
//  Logger.swift
//  dualra1n-loader
//
//  Created by Leonard on 09.04.23.
//

import Foundation

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
        self.verbose = true
    }
    
    func addToLog(_ msg: String) {
        statusText = msg
        log = log + "\n[*] " + msg
        rawLog = rawLog + "\n" + msg
    }
    
    func vLog(_ msg: String) {
        if verbose {
            log = log + "\n" + msg
        }
        rawLog = rawLog + "\n" + msg
    }
}
