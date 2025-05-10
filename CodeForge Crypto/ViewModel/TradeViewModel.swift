import Foundation
import SwiftUI

@MainActor
class TradeViewModel: ObservableObject {
    @Published var amountText: String = ""
    let coin: Coin
    let type: TradeType

    @EnvironmentObject var portfolioVM: PortfolioViewModel 

    init(coin: Coin, type: TradeType) {
        self.coin = coin
        self.type = type
    }


    func attemptTrade() -> Bool {
        guard let amount = Double(amountText), amount > 0 else {
            print("invalid amount")
            return false
        }

        let result = portfolioVM.trade(coin: coin, type: type, amount: amount)
        if result {
            print("successfully\(type == .buy ? "buy" : "sold") \(amount) \(coin.name)")
            amountText = ""
        } else {
            print("failed to \(type == .buy ? "buy" : "sell") \(amount) \(coin.name)")
        }
        return result
    }
}

