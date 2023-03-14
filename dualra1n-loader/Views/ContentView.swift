//
//  ContentView.swift
//  dualra1n
//
//  Created by Uckermark on 16.10.22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var action: Actions
    @State var settings = false
    @State var log = false
    var body: some View {
        ZStack {
            BackgroundView(action: action)
            
            VStack {
                HStack {
                    Button(action: { log.toggle() }) {
                        Image(systemName: "doc.text")
                    }
                    .modifier(transparentButton(padding: 8))
                        .sheet(isPresented: $log) {
                            LogView(action: action)
                        }
                            .padding()
                    Spacer()
                    Button(action: { settings.toggle() }) {
                        Image(systemName: "gearshape")
                    }
                    .modifier(transparentButton(padding: 8))
                        .sheet(isPresented: $settings) {
                            SettingsView(action: action)
                        }
                            .padding()
                }
                Spacer()
                if !FileManager().fileExists(atPath: "/.procursus_strapped") {
                    Button("Jailbreak", action: action.Install)
                        .modifier(transparentButton(padding: 15))
                } else {
                    Button("Re-jailbreak", action: action.runTools)
                        .modifier(transparentButton(padding: 15))
                }
                Text(action.statusText)
                    .foregroundColor(.white)
                Spacer()
                Divider()
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
