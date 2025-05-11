//
//  LoginView.swift
//  CodeForge Crypto
//
//  Created by Ethan on 7/5/2025.
//

import SwiftUI

struct LoginView: View {
    @State private var pin: String = ""
    @State private var isUserAuthenticated = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Enter Your PIN")
                    .font(.title2)
                    .bold()

                PinView(pin: $pin)
                    .onChange(of: pin) {
                        if pin.count == 4 {
                            handlePinEntry()
                        }
                    }
                    .navigationDestination(isPresented: $isUserAuthenticated) {
                        HomeView()
                            .environmentObject(PortfolioViewModel())
                    }

                Button(action: {
                    handlePinEntry()
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(pin.count != 4 ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(pin.count != 4)
                
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func handlePinEntry() {
        // Ensure only numeric input and exactly 4 digits
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else {
            pin = ""
            alertMessage = "PIN must be exactly 4 digits and numeric."
            showAlert = true
            return
        }

        // Validate the PIN against the stored profile
        if let userProfile = ProfileManager.shared.activeProfile {
            if pin == String(userProfile.pin) {
                isUserAuthenticated = true
            } else {
                alertMessage = "Incorrect PIN. \(String(userProfile.pin))"
                pin = ""
                showAlert = true
            }
        }
    }
}

#Preview {
    LoginView()
}
