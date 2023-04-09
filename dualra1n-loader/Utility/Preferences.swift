//
//  Preferences.swift
//  dualra1n-loader
//
//  Created by Uckermark on 14.03.23.
//

import Foundation

class Preferences: ObservableObject {
    @Published var theme: String
    
    static let sharedPreferences = Preferences()
    
    private init() {
        self.theme = UserDefaults.standard.string(forKey: "theme") ?? "Coastal Breeze"
        UserDefaults.standard.set(self.theme, forKey: "theme")
        UserDefaults.standard.synchronize()
    }
    
    func save() {
        UserDefaults.standard.set(self.theme, forKey: "theme")
        UserDefaults.standard.synchronize()
    }
}
