import Foundation

@MainActor
class PortfolioViewModel: ObservableObject {
    @Published var portfolio: Portfolio
    private let storageKey = "jimmy_portfolio"

    init() {
        self.portfolio = Self.loadPortfolioFromStorage()
    }



    var balanceText: String {
        String(format: "$%.2f", portfolio.balance)
    }

    var holdings: [StoredHolding] {
        portfolio.holdings
    }

    var tradeHistory: [TradeRecord] {
        portfolio.tradeHistory
    }



    func charge(amount: Double) {
        guard amount > 0 else {
            print("Charge failed: Invalid amount (\(amount))")
            return
        }

        portfolio.balance += amount
        savePortfolio()
        print("Charge successful: $\(amount), new balance: $\(portfolio.balance)")
    }

    func resetPortfolio() {
        portfolio = Portfolio(balance: 0, holdings: [], tradeHistory: [])
        savePortfolio()
        print("Portfolio has been reset")
    }


    func trade(coin: Coin, type: TradeType, amount: Double) -> Bool {
        guard amount > 0 else {
            print("Trade failed: Invalid amount (\(amount))")
            return false
        }

        let total = coin.currentPrice * amount
        print("Starting trade: \(type == .buy ? "Buy" : "Sell") \(coin.name), unit price $\(coin.currentPrice), quantity \(amount), total $\(total)")

        switch type {
        case .buy:
            print("Processing buy...")
            if portfolio.balance >= total {
                portfolio.balance -= total
                print("Buy successful: deducted $\(total), current balance $\(portfolio.balance)")
                updateHoldings(for: coin, amount: amount)
            } else {
                print("Buy failed: insufficient balance (required $\(total), current $\(portfolio.balance))")
                return false
            }

        case .sell:
            print("Processing sell...")
            guard let index = portfolio.holdings.firstIndex(where: { $0.coinID == coin.id }) else {
                print("Sell failed: no holdings for \(coin.name)")
                return false
            }

            let currentAmount = portfolio.holdings[index].amount
            print("Current holdings for \(coin.name): \(currentAmount)")

            guard currentAmount >= amount else {
                print("Sell failed: insufficient holdings (have \(currentAmount), trying to sell \(amount))")
                return false
            }

            portfolio.holdings[index].amount -= amount
            print("Holdings updated: remaining \(portfolio.holdings[index].amount)")

            if portfolio.holdings[index].amount == 0 {
                portfolio.holdings.remove(at: index)
                print("Holding cleared and removed from portfolio")
            }

            portfolio.balance += total
            print("Sell successful: received $\(total), current balance $\(portfolio.balance)")
        }

        // Add trade record
        let record = TradeRecord(
            coinID: coin.id,
            coinSymbol: coin.symbol,
            coinName: coin.name,
            date: Date(),
            type: type,
            amount: amount,
            currentPrice: coin.currentPrice
        )

        portfolio.tradeHistory.insert(record, at: 0)
        print("Trade record added: \(type == .buy ? "Buy" : "Sell") \(amount) \(coin.name)")

        savePortfolio()
        print("Portfolio data saved")

        return true
    }



  
    private func updateHoldings(for coin: Coin, amount: Double) {
        print("Updating holdings...")
        if let index = portfolio.holdings.firstIndex(where: { $0.coinID == coin.id }) {
            portfolio.holdings[index].amount += amount
            print("Holdings increased: \(coin.name) total \(portfolio.holdings[index].amount)")
        } else {
            let newHolding = StoredHolding(
                coinID: coin.id,
                coinName: coin.name,
                amount: amount
            )
            portfolio.holdings.append(newHolding)
            print("New holding added: \(coin.name), amount \(amount)")
        }
    }

    func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(portfolio) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
            print("Portfolio saved successfully")
        } else {
            print("Save failed: could not encode portfolio data")
        }
    }

    private static func loadPortfolioFromStorage() -> Portfolio {
        let key = "jimmy_portfolio"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(Portfolio.self, from: data) {
            print("Successfully loaded portfolio from local storage")
            return decoded
        } else {
            print("No data found, initializing with mock data")
            return Portfolio(
                balance: Double(MockUser.jimmy.accountBalance),
                holdings: MockUser.jimmy.holdings.map {
                    StoredHolding(coinID: $0.coinID, coinName: $0.coinName, amount: $0.amountHeld)
                },
                tradeHistory: []
            )
        }
    }
}

