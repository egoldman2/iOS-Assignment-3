//
//  CustomNumberPad.swift
//  CodeForge Crypto
//
//  Created by Ethan on 13/5/2025.
//


import SwiftUI

struct CustomNumberPad: View {
    @Binding var pin: String
    
    let gridItems = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    let buttons = [
        "1", "2", "3",
        "4", "5", "6",
        "7", "8", "9",
        "", "0", "⌫"
    ]
    
    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 15) {
            ForEach(buttons, id: \.self) { button in
                if button != "" {
                    Button(action: {
                        if button == "⌫" {
                            pin.removeLast(pin.count > 0 ? 1 : 0)
                        } else {
                            if pin.count < 4 {
                                pin.append(button)
                            }
                        }
                    }) {
                        Text(button)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 70, height: 70)
                            .background(
                                ZStack {
                                    Color.white.opacity(0.2)
                                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                        .shadow(color: .white.opacity(0.2), radius: 5, x: 0, y: 3)
                                }
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    .disabled(button == "")
                } else {
                    Text("")
                }
            }
        }
        .padding(.horizontal, 50)
    }
}

#Preview {
    @State var pin = ""
    
    CustomNumberPad(pin: $pin)
}
