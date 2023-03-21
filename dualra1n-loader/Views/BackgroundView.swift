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
    
    var body: some View {
        Rectangle()
            .modifier(CustomIrregularGradient(prefs: action.prefs))
            .edgesIgnoringSafeArea(.all)
    }
}

struct CustomIrregularGradient: ViewModifier {
    let coastalBreeze: [Color] = [.init(red: 0.0117, green: 0.9725, blue: 0.9882), .init(red: 0.4705, green: 0.9882, blue: 0.1686), .init(red: 0.9411, green: 0.8823, blue: 0.0941), .init(red: 0.2470, green: 0.9490, blue: 0.6118)]
    let sunsetVibes: [Color] = [.orange, .red, .yellow]
    @ObservedObject var prefs: Preferences
    
    func body(content: Content) -> some View {
        if(prefs.theme == "Coastal Breeze") {
            content
                .irregularGradient(colors: coastalBreeze, background: coastalBreeze[0] , animate: true, speed: 0.5)
        }
        else if(prefs.theme == "Sunset Vibes") {
            content
                .irregularGradient(colors: sunsetVibes, background: sunsetVibes[0] , animate: true, speed: 0.5)
        }
        else {
            content
                .irregularGradient(colors: sunsetVibes, background: sunsetVibes[0] , animate: true, speed: 0.5)
        }
    }
}
