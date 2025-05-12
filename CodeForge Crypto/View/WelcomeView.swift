//
//  WelcomeView.swift
//  CodeForge Crypto
//
//  Created by Ethan on 7/5/2025.
//

import SwiftUI

struct WelcomeView: View {
    @State private var navigateToLogin = false
    @State private var navigateToRegistration = false
    @State private var navigateToPinEntry = false
    @State private var currentGradient = 0
    
    // Animated background gradients
    let gradients = [
        [Color(hex: "6B46C1"), Color(hex: "3B82F6")], // Purple to Blue
        [Color(hex: "3B82F6"), Color(hex: "06B6D4")], // Blue to Cyan
        [Color(hex: "06B6D4"), Color(hex: "10B981")], // Cyan to Green
        [Color(hex: "10B981"), Color(hex: "6B46C1")]  // Green to Purple
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: gradients[currentGradient],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 3.0), value: currentGradient)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                        currentGradient = (currentGradient + 1) % gradients.count
                    }
                }
                
                // Glass morphism overlay
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo and App Name
                    VStack(spacing: 24) {
                        // Custom logo design
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "3B82F6"), Color(hex: "6B46C1")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 8) {
                            Text("CodeForge")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("CRYPTO")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .tracking(3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Text("Your Gateway to Digital Assets")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 60)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Continue with PIN (if active profile exists)
                        if ProfileManager.shared.activeProfile != nil {
                            Button(action: {
                                navigateToPinEntry = true
                            }) {
                                HStack {
                                    Image(systemName: "lock.shield.fill")
                                        .font(.system(size: 20))
                                    Text("Continue with PIN")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .foregroundColor(Color(hex: "3B82F6"))
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                        }
                        
                        // Login button
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 20))
                                Text("Login with Email")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(16)
                        }
                        
                        // Create account button
                        Button(action: {
                            navigateToRegistration = true
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus.fill")
                                    .font(.system(size: 20))
                                Text("Create New Account")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        
                        // Terms text
                        Text("By continuing, you accept that all gains are real, all losses are fake news")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
                .navigationDestination(isPresented: $navigateToLogin) {
                    EmailLoginView()
                }
                .navigationDestination(isPresented: $navigateToRegistration) {
                    RegistrationView()
                }
                .navigationDestination(isPresented: $navigateToPinEntry) {
                    LoginView()
                }
            }
        }
        .onAppear {
            ProfileManager.shared.loadProfiles()
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    WelcomeView()
        .onAppear {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
        }
}
