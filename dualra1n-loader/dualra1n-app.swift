//
//  dualra1n-app.swift
//  dualra1n
//
//  Created by Uckermark on 16.10.22.
//

import Foundation
import SwiftUI

@main
struct dualra1nApp {
    static func main() {
        Logger.shared.addToRawLog(JBDevice().getInfoString())
        if #available(iOS 14.0, *) {
            Not_a_bypass.main()
        } else {
            UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(SceneDelegate.self))
        }
    }
}

@available(iOS 14.0, *)
struct Not_a_bypass: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
