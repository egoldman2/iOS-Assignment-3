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
            HStack(spacing: 15) {
                ForEach(0..<4, id: \.self) { index in
                    ZStack {
                        Circle()
                            .strokeBorder(index == pin.count ? Color.black : Color.gray, lineWidth: 4)
                            .frame(width: 50, height: 50)

                        if pin.count > index {
                            Circle()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .padding(.bottom, 10)

            // Hidden text field to capture the input
            TextField("", text: $pin)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01) // Invisible but still captures input
                .onChange(of: pin) {
                    if pin.count > 4 {
                        pin = String(pin.prefix(4))
                    }
                    pin = pin.filter { $0.isNumber }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isFocused = true
                    }
                }
        }
    }
}

#Preview {
    StateWrapper()
}

private struct StateWrapper: View {
    @State var previewPin = ""

    var body: some View {
        PinView(pin: $previewPin)
    }
}
