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
                    .foregroundColor(.black)
                    .sheet(isPresented: $log) {
                        LogView(action: action)
                    }
                        .padding()
                Spacer()
                Button(action: { settings.toggle() }) {
                    Image(systemName: "gearshape")
                }
                    .foregroundColor(.black)
                    .sheet(isPresented: $settings) {
                        SettingsView(action: action)
                    }
                        .padding()
            }
            Spacer()
            if !FileManager().fileExists(atPath: "/.procursus_strapped") {
                Button("Jailbreak", action: action.Install)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(10)
            } else {
                Button("Re-jailbreak", action: action.runTools)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            Text(action.statusText)
                .foregroundColor(.white)
            Spacer()
            Divider()
        }
        //.background(Color(.systemGroupedBackground))
    }
}
