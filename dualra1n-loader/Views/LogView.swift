//
//  LogView.swift
//  dualra1n
//
//  Created by Uckermark on 11.11.22.
//

import SwiftUI

struct LogView: View {
    @ObservedObject var logger: Logger = Logger.shared
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Log")
                        .padding()
                        .font(.headline)
                    Button(action: logger.copyLog) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .padding()
                }
                ScrollView {
                    HStack {
                        Text(logger.rawLog)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
            }
            .padding()
            Text("Nothing here yet...")
                .opacity(logger.rawLog.count > 0 ? 0 : 1)
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}
