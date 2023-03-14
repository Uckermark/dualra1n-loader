//
//  SettingsView.swift
//  dualra1n
//
//  Created by Uckermark on 17.10.22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject var action: Actions
    private let gitCommit = Bundle.main.infoDictionary?["REVISION"] as? String ?? "unknown"
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    
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
                    let themes = ["CyanLagune", "SwiftUI"]
                    Picker("Select Theme", selection: $action.prefs.theme) {
                        ForEach(themes, id: \.self) {
                            Text($0)
                        }
                    }
                    .onDisappear() {
                        action.prefs.save()
                    }
                    .pickerStyle(.menu)
                }
                Section(header: Text("TOOLS"), footer: Text("Restore RootFS is not available yet")) {
                    Button("Rebuild Icon Cache", action: action.runUiCache)
                    Button("Remount R/W", action: action.remountRW)
                    Button("Launch Daemons", action: action.launchDaemons)
                    Button("Respring", action: action.respringJB)
                    Button("Restore RootFS", action: action.respringJB)
                        .disabled(true)
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
        .ignoresSafeArea()
    }
}
