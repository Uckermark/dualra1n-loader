//
//  JailbreakView.swift
//  dualra1n
//
//  Created by Uckermark on 11.11.22.
//

import SwiftUI

struct JailbreakView: View {
    @ObservedObject var action: Actions
    @State var settings = false
    @State var log = false
    var body: some View {
        VStack {
            HStack {
                Button(action: { log.toggle() }) {
                    Image(systemName: "doc.text.magnifyingglass")
                }
                    .modifier(transparentButton())
                    .sheet(isPresented: $log) {
                        LogView(action: action)
                    }
                        .padding()
                Spacer()
                Button(action: { settings.toggle() }) {
                    Image(systemName: "gearshape")
                }
                    .modifier(transparentButton())
                    .sheet(isPresented: $settings) {
                        SettingsView(action: action)
                    }
                        .padding()
            }
            Spacer()
            if !FileManager().fileExists(atPath: "/.procursus_strapped") {
                Button("Jailbreak", action: action.Install)
                    .modifier(transparentButton())
            } else {
                Button("Re-jailbreak", action: action.runTools)
                    .modifier(transparentButton())
            }
            Text(action.statusText)
                .foregroundColor(.white)
            Spacer()
            Divider()
        }
    }
}

struct transparentButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 0.1, leading: 0.1, bottom: 0.1, trailing: 0.1))
            .foregroundColor(.white)
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
    }
}
