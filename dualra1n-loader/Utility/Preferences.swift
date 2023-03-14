//
//  Preferences.swift
//  dualra1n-loader
//
//  Created by Leonard on 14.03.23.
//

import Foundation

class Preferences: ObservableObject {
    @Published var theme: String
    
    init() {
        self.theme = UserDefaults.standard.string(forKey: "theme") ?? "cyanLagune"
    }
    
    func save() {
        UserDefaults.standard.set(theme, forKey: "theme")
        UserDefaults.standard.synchronize()
    }
}
