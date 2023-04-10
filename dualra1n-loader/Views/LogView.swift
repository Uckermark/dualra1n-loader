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
                Text("Log")
                    .padding()
                    .font(.headline)
                ScrollView {
                    HStack {
                        Text(logger.log)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
            }
            .padding()
            Text("Nothing here yet...")
                .opacity(logger.log.count > 0 ? 0 : 1)
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}
