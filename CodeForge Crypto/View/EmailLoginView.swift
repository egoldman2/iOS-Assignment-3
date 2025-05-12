//
//  EmailLoginView.swift
//  CodeForge Crypto
//
//  Created by Ethan on 12/5/2025.
//


import SwiftUI

struct EmailLoginView: View {
    @State private var email: String = ""
    @State private var pin: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false
    @ObservedObject private var profileManager = ProfileManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Login to Your Account")
                .font(.title2)
                .bold()

            TextField("Email Address", text: $email)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("4-digit PIN", text: $pin)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: pin) {
                    if pin.count > 4 {
                        pin = String(pin.prefix(4))
                    }
                    pin = pin.filter { $0.isNumber }
                }

            Button(action: {
                handleLogin()
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValidInput ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!isValidInput)
        }
        .padding()
        .navigationTitle("Login")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
                .environmentObject(PortfolioViewModel())
                .navigationBarBackButtonHidden(true)
        }
    }

    private var isValidInput: Bool {
        !email.isEmpty && pin.count == 4
    }

    private func handleLogin() {
        guard pin.allSatisfy({ $0.isNumber }) else {
            alertMessage = "PIN must be numeric."
            showAlert = true
            return
        }

        // Find the profile with matching email
        if let profile = profileManager.profiles[email] {
            // Verify PIN
            if profile.pin == pin {
                // Successful login
                profileManager.switchProfile(email: email)
                navigateToHome = true
            } else {
                alertMessage = "Incorrect PIN."
                showAlert = true
                pin = ""
            }
        } else {
            alertMessage = "No account found with this email."
            showAlert = true
        }
    }
}
