//
//  HoldingsManager.swift
//  CodeForge Crypto
//
//  Created by Ethan on 6/5/2025.
//

import Foundation

struct Holding: Codable, Identifiable {
    var id: String { coinID }
    let coinID: String
    var coinSymbol: String
    var coinName: String
    var amountHeld: Double

    var totalValueUSD: Double {
        guard let coin = StaticData.first(where: { $0.id == coinID }) else { return 0 }
        return coin.currentPrice * amountHeld
    }
}

class HoldingsManager: ObservableObject {
    static let shared = HoldingsManager()

    @Published private(set) var holdings: [Holding] = []

    private let key = "user_holdings"

    private init() {
        load()
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Holding].self, from: data) {
            holdings = decoded
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(holdings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func updateHolding(for coin: Coin, amount: Double) {
        if let index = holdings.firstIndex(where: { $0.coinID == coin.id }) {
            holdings[index].amountHeld = amount
        } else {
            let newHolding = Holding(coinID: coin.id, coinSymbol: coin.symbol, coinName: coin.name, amountHeld: amount)
            holdings.append(newHolding)
        }
        save()
    }

    func amount(for coinID: String) -> Double {
        holdings.first(where: { $0.coinID == coinID })?.amountHeld ?? 0
    }
}
