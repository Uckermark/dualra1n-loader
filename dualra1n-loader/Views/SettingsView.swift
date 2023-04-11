//
//  SettingsView.swift
//  dualra1n
//
//  Created by Uckermark on 17.10.22.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: JailbreakSettingsView().navigationBarTitle("Jailbreak", displayMode: .inline)) {
                    Text("Jailbreak")
                }
                NavigationLink(destination: ToolsView().navigationBarTitle("Tools", displayMode: .inline)) {
                    Text("Tools")
                }
                NavigationLink(destination: DesignSettingsView().navigationBarTitle("Design", displayMode: .inline)) {
                    Text("Design")
                }
                NavigationLink(destination: LogView().navigationBarTitle("Credits", displayMode: .inline)) {
                    Text("Credits (Coming soon™)")
                }
                .disabled(true)
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct JailbreakSettingsView: View {
    @ObservedObject var logger: Logger = Logger.shared
    var tools: Tools = Tools()
    
    var body: some View {
        List {
            Toggle("Enable Verbose", isOn: $logger.verbose)
            Button("Delete cached bootstrap", action: tools.deleteBootstrap)
            Button("Restore RootFS (experimental)", action: tools.restoreRootFS)
        }
    }
}

struct ToolsView: View {
    var tools: Tools = Tools()
    
    var body: some View {
        List {
            Button("Rebuild Icon Cache", action: tools.runUiCache)
            Button("Remount R/W", action: tools.remountRW)
            Button("Launch Daemons", action: tools.launchDaemons)
            Button("Enable Tweaks", action: tools.enableTweakInjection)
            Button("Respring", action: tools.respringJB)
            Button("Restore Sileo", action: tools.installSileo)
            Button("Add sources", action: tools.addSource)
            Button("Fix deepsleep", action: tools.installDeepsleepFix)
        }
    }
}

struct DesignSettingsView: View {
    @ObservedObject var prefs: Preferences = Preferences.sharedPreferences
    let themes = ["Coastal Breeze", "Sunset Vibes"]
    
    var body: some View {
        List {
            Text("Select theme")
            Picker("", selection: $prefs.theme) {
                ForEach(themes, id: \.self) {
                    Text($0)
                }
            }
            .onDisappear() {
                prefs.save()
            }
            .pickerStyle(.wheel)
        }
    }
}
