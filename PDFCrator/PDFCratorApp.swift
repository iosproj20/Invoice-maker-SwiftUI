//
//  PDFCratorApp.swift
//  PDFCrator
//
//  Created by My Mac on 25/09/24.
//

import SwiftUI
import SwiftData

@main
struct PDFCratorApp: App {
    var body: some Scene {
        WindowGroup {
                    SplashView()
                        .background(Color.blue.opacity(0.8)) // Match the splash screen background
                        .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen
                }
        .modelContainer(for: [PDFEntry.self])
    }
}


struct SplashView: View {
    @State private var isActive = false
    @State private var textVisible = false  // New state for text visibility
    
    var body: some View {
        Group {
            if isActive {
                ContentView()
            } else {
                ZStack {
                    Color.blue.opacity(0.8)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Text("Welcome to Invoice Maker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .opacity(textVisible ? 1 : 0) // Change opacity based on textVisible
                            .scaleEffect(textVisible ? 1 : 0.5) // Scale effect based on textVisible
                            .animation(.easeInOut(duration: 1), value: textVisible) // Animate based on textVisible
                    }
                    .onAppear {
                        // Show text after a slight delay and then change isActive after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                textVisible = true // Make text visible
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.isActive = true // Transition to ContentView
                            }
                        }
                    }
                }
            }
        }
    }
}

