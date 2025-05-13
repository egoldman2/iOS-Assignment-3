import Foundation

// PortfolioViewModel manages the user's portfolio data including balance, holdings, and trade history.
// It supports charging, trading, resetting, and saving/loading portfolio state tied to the active profile.
@MainActor
class PortfolioViewModel: ObservableObject {
    @Published var portfolio: Portfolio
    private var storageKey: String {
        guard let activeEmail = ProfileManager.shared.activeProfile?.email else {
            return "default_portfolio"
        }
        return "portfolio_\(activeEmail)"
    }

    // Initializes the portfolio based on the active user profile.
    // Also sets up a listener to handle profile switches and reload the corresponding portfolio.
    init() {
        if let activeEmail = ProfileManager.shared.activeProfile?.email {
            self.portfolio = Self.loadPortfolioFromStorage(key: "portfolio_\(activeEmail)")
        } else {
            self.portfolio = Portfolio(balance: 0, holdings: [], tradeHistory: [])
        }

        // Listen for profile switches
        NotificationCenter.default.addObserver(self, selector: #selector(onProfileSwitched), name: NSNotification.Name("ProfileSwitched"), object: nil)
    }

    @objc private func onProfileSwitched() {
        if let activeEmail = ProfileManager.shared.activeProfile?.email {
            self.portfolio = Self.loadPortfolioFromStorage(key: "portfolio_\(activeEmail)")
        }
    }
    
    // Add this method
    // Reloads the portfolio data based on the current active profile, replacing any in-memory changes.
    func resetAndReload() {
        if let activeEmail = ProfileManager.shared.activeProfile?.email {
            self.portfolio = Self.loadPortfolioFromStorage(key: "portfolio_\(activeEmail)")
        } else {
            self.portfolio = Portfolio(balance: 0, holdings: [], tradeHistory: [])
        }
        objectWillChange.send()
    }

    // Computed properties to expose formatted balance, holdings list, and trade history.
    var balanceText: String {
        String(format: "$%.2f", portfolio.balance)
    }

    // Computed properties to expose formatted balance, holdings list, and trade history.
    var holdings: [StoredHolding] {
        portfolio.holdings
    }

    // Computed properties to expose formatted balance, holdings list, and trade history.
    var tradeHistory: [TradeRecord] {
        portfolio.tradeHistory
    }

    // Adds the specified amount to the balance, then saves the updated portfolio.
    func charge(amount: Double) {
        guard amount > 0 else {
            print("Charge failed: Invalid amount (\(amount))")
            return
        }

        portfolio.balance += amount
        savePortfolio()
        print("Charge successful: $\(amount), new balance: $\(portfolio.balance)")
    }

    // Clears all portfolio data and saves the empty portfolio.
    func resetPortfolio() {
        portfolio = Portfolio(balance: 0, holdings: [], tradeHistory: [])
        savePortfolio()
        print("Portfolio has been reset")
    }

    // Handles buying or selling a specific coin.
    // Validates inputs, updates holdings and balance, appends a trade record, and saves the portfolio.
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

    // Adds to or removes from coin holdings depending on trade type.
    // If the coin doesn't exist in holdings, it creates a new entry.
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

    // Encodes and saves the portfolio to UserDefaults using the profile-specific key.
    func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(portfolio) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
            print("Portfolio saved successfully for profile: \(storageKey)")
        } else {
            print("Save failed: could not encode portfolio data")
        }
    }

    private static func loadPortfolioFromStorage(key: String) -> Portfolio {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(Portfolio.self, from: data) {
            print("Successfully loaded portfolio for key: \(key)")
            return decoded
        } else {
            print("No data found for key: \(key), initializing with empty portfolio")
            return Portfolio(balance: 0, holdings: [], tradeHistory: [])
        }
    }
}
