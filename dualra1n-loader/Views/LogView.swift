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
            Text("Nothing here yet...")
                .opacity(action.log.count > 0 ? 0 : 1)
            ScrollView {
                HStack {
                    Text(action.log)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            VStack {
                Spacer()
                Divider()
            }
        }
        //.background(Color(.systemGroupedBackground))
    }
}
