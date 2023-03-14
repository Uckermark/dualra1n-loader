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
    var body: some View {
        let themes: [[Color]] = [
            [.init(red: 0.011765, green: 0.972549, blue: 0.988235), .init(red: 0.470588, green: 0.988235, blue: 0.168627), .init(red: 0.941176, green: 0.882352, blue: 0.094118)],
            [.init(red: 0, green: 0, blue: 0), .init(red: 0, green: 0, blue: 0), .init(red: 0, green: 0, blue: 0)]]
        Rectangle()
            .irregularGradient(colors: themes[0], background: themes[0][0], animate: true, speed: 0.5)
            .blur(radius: 25)
            .ignoresSafeArea()
    }
}

/*
struct GradientBackground: View {
    var colors: [Color]
    let interval = 5
    @State private var startPoint = UnitPoint(x: 0, y: 0)
    @State private var endPoint = UnitPoint(x: 1, y: 1)
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
            .animation(.easeInOut(duration: Double(interval)).repeatForever(autoreverses: true))
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { _ in
                    self.randomizeStartAndEndPoints()
                }
            }
    }
    
    private func randomizeStartAndEndPoints() {
        let x1 = Double.random(in: 0...0.8)
        let y1 = Double.random(in: 0...0.8)
        let x2 = Double.random(in: 0.3...1)
        let y2 = Double.random(in: 0.3...1)
        startPoint = UnitPoint(x: x1, y: y1)
        endPoint = UnitPoint(x: x2, y: y2)
    }
}

extension Color {
    func adjusted(toSaturation saturation: Double, brightness: Double) -> Color {
        var hue: CGFloat = 0
        var saturationComponent: CGFloat = 0
        var brightnessComponent: CGFloat = 0
        var alphaComponent: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturationComponent, brightness: &brightnessComponent, alpha: &alphaComponent)
        saturationComponent *= CGFloat(saturation)
        brightnessComponent *= CGFloat(brightness)
        return Color(UIColor(hue: hue, saturation: saturationComponent, brightness: brightnessComponent, alpha: alphaComponent))
    }
}
*/
