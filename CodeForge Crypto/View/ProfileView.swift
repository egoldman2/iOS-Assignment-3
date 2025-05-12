//
//  ProfileView 2.swift
//  CodeForge Crypto
//
//  Created by Ethan on 7/5/2025.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var manager = ProfileManager.shared
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @State private var showDeleteConfirmation = false
    @State private var navigateToWelcome = false
    @State private var navigateToPinLock = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .bold()

                Text("Name: \(manager.activeProfile?.name ?? "N/A")")
                Text("Email: \(manager.activeProfile?.email ?? "N/A")")
                Text("PIN: ****")
                Divider()
                
                Text("Holdings:")
                    .font(.title2)
                    .bold()
                
                List(manager.activeProfile?.holdings ?? []) { holding in
                    HStack {
                        Text(holding.coinSymbol)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(holding.amountHeld, specifier: "%.4f")")
                            .frame(width: 80, alignment: .trailing)
                        Text(String(format: "$%.2f", holding.totalValueUSD))
                            .frame(width: 100, alignment: .trailing)
                    }
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    // Lock Button
                    Button(action: {
                        navigateToPinLock = true
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Lock App")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    // Sign Out Button
                    Button(action: {
                        signOut()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                            Text("Sign Out")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    // Delete Account Button
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete Account")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to permanently delete your account? This action cannot be undone.")
            }
            .navigationDestination(isPresented: $navigateToWelcome) {
                WelcomeView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToPinLock) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func signOut() {
        // IMPORTANT: Don't clear the profile data from storage
        // Just remove the active profile reference
        
        // Save any pending changes before signing out
        manager.saveProfiles()
        
        // Clear only the active session, not the stored profile
        manager.activeProfile = nil
        UserDefaults.standard.removeObject(forKey: "active_profile")
        
        // Navigate back to welcome screen
        navigateToWelcome = true
    }
    
    private func deleteAccount() {
        guard let email = manager.activeProfile?.email else { return }
        
        // This is where we actually delete the account permanently
        manager.deleteProfile(email: email)
        
        // Clear portfolio data from UserDefaults for this user
        let portfolioKey = "portfolio_\(email)"
        UserDefaults.standard.removeObject(forKey: portfolioKey)
        
        // Clear any other user-specific data
        UserDefaults.standard.removeObject(forKey: "active_profile")
        
        // Reset portfolio view model
        portfolioVM.resetPortfolio()
        
        // Navigate back to welcome screen
        navigateToWelcome = true
    }
}

#Preview {
    ProfileView()
        .environmentObject(PortfolioViewModel())
}
