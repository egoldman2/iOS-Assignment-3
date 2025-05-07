//
//  ProfileView 2.swift
//  CodeForge Crypto
//
//  Created by Ethan on 7/5/2025.
//


import SwiftUI

struct ProfileView: View {
    @ObservedObject private var manager = ProfileManager.shared

    var body: some View {
        VStack(spacing: 20) {
            if let profile = manager.profile {
                Text("Profile")
                    .font(.largeTitle)
                    .bold()

                Text("Name: \(profile.name)")
                Text("Email: \(profile.email)")
                Text("PIN: ****")
                Divider()
                
                Text("Holdings:")
                    .font(.title2)
                    .bold()
                
                List(profile.holdings) { holding in
                    HStack {
                        Text(holding.coinSymbol)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(holding.amountHeld, specifier: "%.4f")")
                            .frame(width: 80, alignment: .trailing)
                        Text(String(format: "$%.2f", holding.totalValueUSD))
                            .frame(width: 100, alignment: .trailing)
                    }
                }
            } else {
                Text("No profile found.")
            }
        }
        .padding()
    }
}