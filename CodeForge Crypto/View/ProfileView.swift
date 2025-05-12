//
//  ProfileView.swift
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
                // Profile Header
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    Text("Profile")
                        .font(.largeTitle)
                        .bold()
                }
                .padding()
                
                // User Info Card
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
                
                // Action Buttons
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
        manager.activeProfile = nil
        UserDefaults.standard.removeObject(forKey: "active_profile")
        portfolioVM.resetPortfolio()
        navigateToWelcome = true
    }
    
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
