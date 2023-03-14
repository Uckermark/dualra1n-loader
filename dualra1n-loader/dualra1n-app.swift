//
//  dualra1n-app.swift
//  dualra1n
//
//  Created by Uckermark on 16.10.22.
//

import Foundation
import SwiftUI

@main
struct dualra1nApp: App {
    var action: Actions
    
    init() {
        action = Actions()
    }
    var body: some Scene {
        WindowGroup {
            ContentView(action: action)
        }
    }
}
