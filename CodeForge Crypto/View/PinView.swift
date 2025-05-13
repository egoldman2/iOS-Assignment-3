//
//  PinView.swift
//  CodeForge Crypto
//
//  Created by Ethan on 7/5/2025.
//

import SwiftUI

struct PinView: View {
    // PinView renders a 4-digit PIN input as a row of stylized circles.
    // Each circle shows a filled dot if a digit has been entered.
    @Binding var pin: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            // Create four PIN input circles with visual feedback based on index and pin length
            HStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(pin.count > index ? 0.2 : 0.1))
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(index == pin.count ? 0.6 : 0.2), lineWidth: 2)
                            )

                        if pin.count > index {
                            Text("•")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

// Preview showing PinView over a gradient background using a wrapper for state binding
#Preview {
    ZStack {
        // Background to see the effect
        LinearGradient(
            colors: [Color.purple, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        StateWrapper()
    }
}

// A helper view that provides a @State binding for use in the PinView preview
private struct StateWrapper: View {
    @State var previewPin = ""

    var body: some View {
        PinView(pin: $previewPin)
    }
}
