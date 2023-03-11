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
                    .foregroundColor(.white)
                    .sheet(isPresented: $log) {
                        LogView(action: action)
                    }
                        .padding()
                Spacer()
                Button(action: { settings.toggle() }) {
                    Image(systemName: "gearshape")
                }
                    .foregroundColor(.white)
                    .sheet(isPresented: $settings) {
                        SettingsView(action: action)
                    }
                        .padding()
            }
            Spacer()
            if !FileManager().fileExists(atPath: "/.procursus_strapped") {
                Button("Jailbreak", action: action.Install)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                Button("Re-jailbreak", action: action.runTools)
            }
            Spacer()
            Divider()
        }
        //.background(Color(.systemGroupedBackground))
    }
}
