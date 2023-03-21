//
//  LogView.swift
//  dualra1n
//
//  Created by Uckermark on 11.11.22.
//

import SwiftUI

struct LogView: View {
    @ObservedObject var action: Actions
    var body: some View {
        ZStack {
            VStack {
                Text("Log")
                    .padding()
                    .font(.headline)
                ScrollView {
                    HStack {
                        Text(action.log)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
            }
            .padding()
            Text("Nothing here yet...")
                .opacity(action.log.count > 0 ? 0 : 1)
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}
