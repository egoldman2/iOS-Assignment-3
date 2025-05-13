//
//  HoldingsManager.swift
//  CodeForge Crypto
//
//  Created by Ethan on 6/5/2025.
//

import Foundation

// Represents a user's individual crypto holding
struct Holding: Codable, Identifiable {
    var id: String { coinID } // Conform to Identifiable using coin ID
    let coinID: String
    var coinSymbol: String
    var coinName: String
    var amountHeld: Double

    // Computes the current value of this holding in USD using static price data
    var totalValueUSD: Double {
        guard let coin = StaticData.first(where: { $0.id == coinID }) else { return 0 }
        return coin.currentPrice * amountHeld
    }
}

// Manages the user's holdings: loading, saving, and updating persistent data
class HoldingsManager: ObservableObject {
    static let shared = HoldingsManager()

    @Published private(set) var holdings: [Holding] = []

    private let key = "user_holdings"

    // Loads holdings from UserDefaults on initialization
    private init() {
        load()
    }

    // Load saved holdings from persistent storage
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Holding].self, from: data) {
            holdings = decoded
        }
    }

    // Save current holdings to persistent storage
    func save() {
        if let data = try? JSONEncoder().encode(holdings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // Add or update a holding with a new amount
    func updateHolding(for coin: Coin, amount: Double) {
        if let index = holdings.firstIndex(where: { $0.coinID == coin.id }) {
            holdings[index].amountHeld = amount
        } else {
            let newHolding = Holding(coinID: coin.id, coinSymbol: coin.symbol, coinName: coin.name, amountHeld: amount)
            holdings.append(newHolding)
        }
        save()
    }

    // Get the amount held for a specific coin
    func amount(for coinID: String) -> Double {
        holdings.first(where: { $0.coinID == coinID })?.amountHeld ?? 0
    }
}
