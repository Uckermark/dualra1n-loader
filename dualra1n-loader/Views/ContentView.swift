//
//  ContentView.swift
//  dualra1n
//
//  Created by Uckermark on 16.10.22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var action: Actions
    var body: some View {
        ZStack {
            BackgroundView()
            JailbreakView(action: action)
        }
    }
}
