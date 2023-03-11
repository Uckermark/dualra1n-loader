//
//  ContentView.swift
//  dualra1n
//
//  Created by Uckermark on 16.10.22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var action: Actions
    @State private var showTools = false
    @State private var showSettings = false
    init(act: Actions) {
        action = act
    }
    var body: some View {
        ZStack {
            BackgroundView()
            JailbreakView(action: action)
        }
    }
}
