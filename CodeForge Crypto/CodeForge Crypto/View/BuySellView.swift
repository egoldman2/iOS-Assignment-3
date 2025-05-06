//
//  BuySellView.swift
//  CodeForge Crypto
//
//  Created by Ethan on 6/5/2025.
//
import SwiftUI

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
            
            TextField("Amount", text: $amountText)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
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
