//
//  BuySellView.swift
//  CodeForge Crypto
//
//  Created by Ethan on 6/5/2025.
//

import SwiftUI

// View for buying or selling a specific cryptocurrency.
// Displays a simple form with amount input and Buy/Sell buttons.
// Updates the user's holdings and dismisses on action.
struct BuySellView: View {
    let coin: Coin
    @Environment(\.dismiss) var dismiss
    @State private var amountText: String = ""
    @ObservedObject private var holdingsManager = HoldingsManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Trade \(coin.name)")
                .font(.title)
                .bold()
            
            // User inputs the trade amount
            TextField("Amount", text: $amountText)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Buy and Sell buttons trigger the trade logic
            HStack(spacing: 20) {
                Button("Buy") {
                    applyTrade(isBuying: true)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Sell") {
                    applyTrade(isBuying: false)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
    
    // Applies the trade by calculating the new holding amount
    // Ensures the holding does not go negative and updates the holdings manager
    private func applyTrade(isBuying: Bool) {
        guard let amount = Double(amountText) else { return }
        let currentAmount = holdingsManager.amount(for: coin.id)
        let newAmount = max(0, isBuying ? currentAmount + amount : currentAmount - amount)
        holdingsManager.updateHolding(for: coin, amount: newAmount)
        dismiss()
    }
}

#Preview {
    BuySellView(coin: StaticData[0])
}
