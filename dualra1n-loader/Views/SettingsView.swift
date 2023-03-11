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
            List {
                Section(header: Text("SETTINGS")) {
                    Toggle("Enable Verbose", isOn: $action.verbose)
                }
                Section(header: Text("TOOLS")) {
                    Button("Rebuild Icon Cache", action: action.runUiCache)
                    Button("Remount Preboot", action: action.remountPreboot)
                    Button("Launch Daemons", action: action.launchDaemons)
                    Button("Respring", action: action.respringJB)
                    Button("Restore RootFS", action: action.respringJB)
                        .disabled(true)
                }
            }
            Spacer()
            HStack {
                Text("v\(version) (\(gitCommit))")
                Spacer()
            }
            Divider()
        }
        //.background(Color(.systemGroupedBackground))
    }
}
