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
                            .strokeBorder(Color.gray, lineWidth: 1)
                            .frame(width: 50, height: 50)

                        Text(pin.count > index ? String(pin[pin.index(pin.startIndex, offsetBy: index)]) : "")
                            .font(.title2)
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
                .onChange(of: pin) { newValue in
                    if newValue.count > 4 {
                        pin = String(newValue.prefix(4))
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