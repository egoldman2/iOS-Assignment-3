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
    @FocusState private var emailFocused: Bool
    @FocusState private var pinFocused: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glass morphism overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.7)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color.white.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Text("Welcome Back")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Login to your account")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            TextField("name@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($emailFocused)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(emailFocused ? Color.white.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        
                        // PIN Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("4-Digit PIN")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            SecureField("••••", text: $pin)
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                                .focused($pinFocused)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(pinFocused ? Color.white.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .onChange(of: pin) { _, newValue in
                                    // Only allow numbers
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    
                                    // Limit to exactly 4 digits
                                    if filtered.count > 4 {
                                        pin = String(filtered.prefix(4))
                                    } else {
                                        pin = filtered
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Login Button
                    Button(action: handleLogin) {
                        Text("Login")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: isValidInput ? [Color.green, Color.cyan] : [Color.gray, Color.gray.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .disabled(!isValidInput)
                    .padding(.horizontal, 40)
                    
                    // Forgot PIN
                    Button(action: {}) {
                        Text("Forgot your PIN?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
                .environmentObject(PortfolioViewModel())
                .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            emailFocused = true
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

        if let profile = profileManager.profiles[email] {
            if profile.pin == pin {
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

#Preview {
    NavigationStack {
        EmailLoginView()
    }
}
