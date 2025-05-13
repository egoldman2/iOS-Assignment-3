//
//  ProfileView.swift
//  CodeForge Crypto
//
//  Created by Ethan on 7/5/2025.
//

import SwiftUI

// ProfileView displays account settings and actions for the logged-in user.
// Includes viewing profile details, recharging account, locking the app,
// signing out, and permanently deleting the account.
struct ProfileView: View {
    @ObservedObject private var manager = ProfileManager.shared
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @State private var showDeleteConfirmation = false
    @State private var navigateToWelcome = false
    @State private var navigateToPinLock = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header with profile icon and title
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    Text("Profile")
                        .font(.largeTitle)
                        .bold()
                }
                .padding()
                
                // User information card showing avatar, name, email, and PIN hint
                VStack(spacing: 15) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Text(manager.activeProfile?.name.prefix(1).uppercased() ?? "?")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 8) {
                        Text(manager.activeProfile?.name ?? "N/A")
                            .font(.title2)
                            .bold()
                        
                        Text(manager.activeProfile?.email ?? "N/A")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("PIN: ****")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Action buttons: Recharge, Lock App, Sign Out, and Delete Account
                VStack(spacing: 12) {
                    // Recharge Button
                    NavigationLink(destination: RechargeView().environmentObject(portfolioVM)) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 20))
                            Text("Recharge Account")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(10)
                    }
                    
                    // Lock Button
                    Button(action: { navigateToPinLock = true }) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                            Text("Lock App")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                    }
                    
                    // Sign Out Button
                    Button(action: signOut) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                                .font(.system(size: 20))
                            Text("Sign Out")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                    
                    // Delete Account Button
                    Button(action: { showDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 20))
                            Text("Delete Account")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            // Confirmation alert shown when attempting to delete account
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to permanently delete your account? This action cannot be undone.")
            }
            // Navigate to WelcomeView after sign-out or account deletion
            .navigationDestination(isPresented: $navigateToWelcome) {
                WelcomeView()
                    .navigationBarBackButtonHidden(true)
            }
            // Navigate to LoginView when locking the app
            .navigationDestination(isPresented: $navigateToPinLock) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    // Clears current profile and navigates to welcome screen
    private func signOut() {
        manager.activeProfile = nil
        UserDefaults.standard.removeObject(forKey: "active_profile")
        portfolioVM.resetPortfolio()
        navigateToWelcome = true
    }
    
    // Deletes user profile and associated data, then navigates to welcome screen
    private func deleteAccount() {
        guard let email = manager.activeProfile?.email else { return }
        manager.deleteProfile(email: email)
        let portfolioKey = "portfolio_\(email)"
        UserDefaults.standard.removeObject(forKey: portfolioKey)
        UserDefaults.standard.removeObject(forKey: "active_profile")
        portfolioVM.resetPortfolio()
        navigateToWelcome = true
    }
}

#Preview {
    ProfileView()
        .environmentObject(PortfolioViewModel())
}
