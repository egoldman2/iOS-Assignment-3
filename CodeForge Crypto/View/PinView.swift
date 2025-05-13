//
//  PinView.swift
//  CodeForge Crypto
//
//  Created by Ethan on 7/5/2025.
//

import SwiftUI

struct PinView: View {
    @Binding var pin: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
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

private struct StateWrapper: View {
    @State var previewPin = ""

    var body: some View {
        PinView(pin: $previewPin)
    }
}
