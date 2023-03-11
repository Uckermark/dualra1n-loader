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
        UITabBar.appearance().backgroundColor = .systemGroupedBackground
        action = act
    }
    var body: some View {
        TabView {
            JailbreakView(action: action)
                .tabItem {
                    Label("Jailbreak", systemImage: "wand.and.stars")
                }
            LogView(action: action)
                .tabItem {
                    Label("Log", systemImage: "doc.text.magnifyingglass")
            }
            SettingsView(action: action)
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver")
                }
        }
    }
}


// This is not ready yet. Needs to be tested on a real device
struct BackgroundView: View {
    var body: some View {
            ZStack {
                // Create a custom gradient background that animates randomly
                GradientBackground(colors: [Color.purple, .pink, .blue].map { $0.adjusted(toSaturation: 1.5, brightness: 0.8) })
                
                // Add your other views on top of the gradient background
                Text("Hello, world!")
                    .foregroundColor(.white)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }

    struct GradientBackground: View {
        var colors: [Color]
        let interval = 30
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
            let x1 = Double.random(in: 0...1)
            let y1 = Double.random(in: 0...1)
            let x2 = Double.random(in: 0...1)
            let y2 = Double.random(in: 0...1)
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
