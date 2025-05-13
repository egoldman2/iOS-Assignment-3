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
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.purple, Color.blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Glass morphism overlay
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // User Profile Info
                    if let profile = profileManager.activeProfile {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white, Color.white.opacity(0.9)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                                Text(profile.name.prefix(1).uppercased())
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.purple)
                            }

                            VStack {
                                Text("Welcome back")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                Text(profile.name)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }

                            
                        }
                    }
                    
                    // PIN Entry
                    VStack(spacing: 24) {
                        Text("Enter Your PIN")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        // Custom PIN View with modern styling
                        PinView(pin: $pin)
                            .disabled(true)
                            .onChange(of: pin) { _, _ in
                                if pin.count == 4 {
                                    handlePinEntry()
                                }
                            }
                    }
                    
                    CustomNumberPad(pin: $pin)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        
                        
                        Button(action: {
                            handlePinEntry()
                        }) {
                            Text("Login")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: pin.count == 4 ? [Color.green, Color.cyan] : [Color.gray, Color.gray.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        .disabled(pin.count != 4)
                        
                        Button(action: {
                            profileManager.activeProfile = nil
                            UserDefaults.standard.removeObject(forKey: "active_profile")
                            pin = ""
                            navigateToWelcome = true
                        }) {
                            Text("Switch Account")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                    
                    
                }
            }
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
