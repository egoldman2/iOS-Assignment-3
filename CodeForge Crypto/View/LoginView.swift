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
    @State private var navigateToWelcome = false
    @ObservedObject private var profileManager = ProfileManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let profile = profileManager.activeProfile {
                    Text("Welcome back, \(profile.name)!")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 20)
                }

                Text("Enter Your PIN")
                    .font(.title2)
                    .bold()

                PinView(pin: $pin)
                    .onChange(of: pin) {
                        if pin.count == 4 {
                            handlePinEntry()
                        }
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
                
                // Switch Account button
                Button(action: {
                    profileManager.activeProfile = nil
                    UserDefaults.standard.removeObject(forKey: "active_profile")
                    pin = ""
                    navigateToWelcome = true
                }) {
                    Text("Switch Account")
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $isUserAuthenticated) {
                HomeView()
                    .environmentObject(PortfolioViewModel())
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToWelcome) {
                WelcomeView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    private func handlePinEntry() {
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else {
            pin = ""
            alertMessage = "PIN must be exactly 4 digits and numeric."
            showAlert = true
            return
        }

        if let userProfile = profileManager.activeProfile {
            if pin == userProfile.pin {
                isUserAuthenticated = true
            } else {
                alertMessage = "Incorrect PIN."
                pin = ""
                showAlert = true
            }
        } else {
            alertMessage = "No active profile found."
            showAlert = true
        }
    }
}

#Preview {
    LoginView()
}
