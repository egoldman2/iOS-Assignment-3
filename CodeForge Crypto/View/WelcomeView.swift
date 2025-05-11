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

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 50) {
                    Image("logo")
                        .resizable()
                        .frame(width: 180, height: 180)
                        .cornerRadius(90)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                    Text("Welcome to CodeForge Crypto!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)

                    Spacer()

                    Button(action: {
                        if ProfileManager.shared.profile != nil {
                            navigateToLogin = true
                        } else {
                            navigateToRegistration = true
                        }
                    }) {
                        Text("Get Started / Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 40)

                    Spacer()
                }
                .navigationDestination(isPresented: $navigateToLogin) {
                    LoginView()
                }
                .navigationDestination(isPresented: $navigateToRegistration) {
                    RegistrationView()
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
        .onAppear {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
        }
}
