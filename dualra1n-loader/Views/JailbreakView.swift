//
//  JailbreakView.swift
//  dualra1n
//
//  Created by Uckermark on 11.11.22.
//

import SwiftUI

struct JailbreakView: View {
    @ObservedObject var action: Actions
    
    var body: some View {
        VStack {
            Spacer()
            if !FileManager().fileExists(atPath: "/.procursus_strapped") {
                Button("Jailbreak", action: action.Install)
            } else {
                Button("Re-jailbreak", action: action.runTools)
            }
            Spacer()
            Divider()
        }
        .background(Color(.systemGroupedBackground))
    }
}
