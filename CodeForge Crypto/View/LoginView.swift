import SwiftUI

struct LoginView: View {
    @State private var pin: String = ""
    @State private var isUserAuthenticated = false
    @State private var showSetPinPrompt = false
    @AppStorage("userPin") private var storedPin: String?

    var body: some View {
        VStack(spacing: 20) {
            Text(isUserAuthenticated ? "Welcome Back!" : "Enter Your PIN")
                .font(.title2)
                .bold()

            SecureField("Enter 4-digit PIN", text: $pin)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)

            Button(action: {
                handlePinEntry()
            }) {
                Text(isUserAuthenticated ? "Continue" : "Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(pin.count != 4)

            if showSetPinPrompt {
                Text("No PIN found, please set your 4-digit PIN:")
                SecureField("Set PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
            }
        }
        .padding()
        .alert(isPresented: $isUserAuthenticated) {
            Alert(title: Text("Login Successful"), message: Text("Welcome to CodeForge Crypto!"), dismissButton: .default(Text("Continue")))
        }
    }

    private func handlePinEntry() {
        if let savedPin = storedPin {
            if pin == savedPin {
                isUserAuthenticated = true
            } else {
                pin = ""
            }
        } else {
            showSetPinPrompt = true
            storedPin = pin
            isUserAuthenticated = true
        }
    }
}