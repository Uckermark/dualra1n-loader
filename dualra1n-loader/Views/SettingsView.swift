//
//  SettingsView.swift
//  dualra1n
//
//  Created by Uckermark on 17.10.22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var action: Actions
    private let gitCommit = Bundle.main.infoDictionary?["REVISION"] as? String ?? "unknown"
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    
    let themes = ["Coastal Breeze", "Sunset Vibes"]
    
    init(action: Actions) {
        self.action = action
    }
    var body: some View {
        VStack {
            Text("Settings")
                .padding()
                .font(.headline)
            List {
                Section(header: Text("SETTINGS")) {
                    Toggle("Enable Verbose", isOn: $action.verbose)
                }
                Section(header: Text("TOOLS")) {
                    Button("Rebuild Icon Cache", action: action.runUiCache)
                    Button("Remount R/W", action: action.remountRW)
                    Button("Launch Daemons", action: action.launchDaemons)
                    Button("Respring", action: action.respringJB)
                }
                Section(header: Text("DESIGN")) {
                    Text("Select theme")
                    Picker("", selection: $action.prefs.theme) {
                        ForEach(themes, id: \.self) {
                            Text($0)
                        }
                    }
                    .onDisappear() {
                        action.prefs.save()
                    }
                    .pickerStyle(.wheel)
                }
            }
            Spacer()
            HStack {
                Text("v\(version) (\(gitCommit))")
                    .padding()
                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}
