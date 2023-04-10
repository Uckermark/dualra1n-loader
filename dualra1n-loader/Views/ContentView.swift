//
//  ContentView.swift
//  dualra1n
//
//  Created by Uckermark on 16.10.22.
//

import SwiftUI

struct ContentView: View {
    @State var settings = false
    @State var log = false
    @ObservedObject var logger: Logger = Logger.shared
    @ObservedObject var installer: Installer = Installer()
    var tools: Tools = Tools()
    private let gitCommit = Bundle.main.infoDictionary?["REVISION"] as? String ?? "unknown"
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                HStack {
                    Button(action: { log.toggle() }) {
                        Image(systemName: "doc.text")
                    }
                    .modifier(transparentButton(padding: 8))
                        .sheet(isPresented: $log) {
                            LogView()
                        }
                            .padding()
                    Spacer()
                    Button(action: { settings.toggle() }) {
                        Image(systemName: "gear")
                    }
                    .modifier(transparentButton(padding: 8))
                        .sheet(isPresented: $settings) {
                            SettingsView()
                        }
                            .padding()
                }
                Spacer()
                if !FileManager().fileExists(atPath: "/.procursus_strapped") {
                    Button("Jailbreak", action: installer.bootstrap)
                        .modifier(transparentButton(padding: 15))
                } else {
                    Button("Re-jailbreak", action: tools.reJailbreak)
                        .modifier(transparentButton(padding: 15))
                }
                Text(logger.statusText)
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    Spacer()
                    Text("v\(version) (\(gitCommit))")
                        .font(.system(size: 13.0))
                        .padding()
                }
            }
        }
    }
}

struct transparentButton: ViewModifier {
    let insets: EdgeInsets
    init(padding: CGFloat) {
        insets = EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
    }
    func body(content: Content) -> some View {
        content
            .padding(insets)
            .foregroundColor(.white)
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
    }
}
