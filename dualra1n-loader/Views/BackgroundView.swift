//
//  BackgroundView.swift
//  dualra1n
//
//  Created by Uckermark on 11.03.23.
//

import SwiftUI
import IrregularGradient


// This is not ready yet. Needs to be tested on a real device
struct BackgroundView: View {
    @ObservedObject var action: Actions
    let cyanLagune: [Color] = [.init(red: 0.0117, green: 0.9725, blue: 0.9882), .init(red: 0.4705, green: 0.9882, blue: 0.1686), .init(red: 0.9411, green: 0.8823, blue: 0.0941), .init(red: 0.2470, green: 0.9490, blue: 0.6118)]
    let swiftui: [Color] = [.orange, .red, .yellow]
    var body: some View {
        let themes = ["CyanLagune": cyanLagune, "SwiftUI": swiftui] // TODO: add more themes & theme manager
        Rectangle()
            .irregularGradient(colors: themes[action.prefs.theme] ?? themes["CyanLagune"]!, background: themes[action.prefs.theme]?[0], animate: true, speed: 0.5)
            .ignoresSafeArea()
    }
}
