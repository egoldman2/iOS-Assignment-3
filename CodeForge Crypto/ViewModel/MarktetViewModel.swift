import Foundation

@MainActor
class MarketViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var searchText: String = ""
    private(set) var hasLoaded: Bool = false

    //
    func fetchCoins() async {
        guard !hasLoaded else {
            print("Skipped fetchCoins: already loaded.")
            return
        }

        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=aud&order=market_cap_desc&per_page=10&page=1&sparkline=false"

        guard let url = URL(string: urlString) else {
            handle(error: .invalidResponse)
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([Coin].self, from: data)
            self.coins = decoded
            self.hasLoaded = true
            print(" Loaded live API data:")
            decoded.forEach { print($0) }
        } catch is DecodingError {
            handle(error: .decodingError)
        } catch {
            handle(error: .apiFailure)
        }
    }

    private func handle(error: AppError) {
        print(" Error: \(error.localizedDescription)")
        self.coins = StaticData
        self.hasLoaded = true
        print(" Loaded backup static data:")
        StaticData.forEach { print($0) }
    }


    func clearCache() {
        self.coins = []
        self.hasLoaded = false
        print("Cache cleared, will fetch again next time.")
    }


    func sortCoins(by key: String, reverse: Bool = false) {
        let sortedCoins: [Coin]
        switch key {
        case "marketCap":
            sortedCoins = coins.sorted { reverse ? $0.marketCap < $1.marketCap : $0.marketCap > $1.marketCap }
        case "price":
            sortedCoins = coins.sorted { reverse ? $0.currentPrice < $1.currentPrice : $0.currentPrice > $1.currentPrice }
        case "volume":
            sortedCoins = coins.sorted { reverse ? $0.totalVolume < $1.totalVolume : $0.totalVolume > $1.totalVolume }
        case "change24h":
            sortedCoins = coins.sorted { reverse ? $0.priceChangePercentage24h < $1.priceChangePercentage24h : $0.priceChangePercentage24h > $1.priceChangePercentage24h }
        default:
            sortedCoins = coins.sorted { reverse ? $0.marketCap < $1.marketCap : $0.marketCap > $1.marketCap }
        }

        self.coins = sortedCoins
    }


    var trendingCoins: [Coin] {
        coins.sorted(by: { $0.marketCap > $1.marketCap }).prefix(10).map { $0 }
    }

    var topGainers: [Coin] {
        coins.sorted(by: { $0.priceChangePercentage24h > $1.priceChangePercentage24h }).prefix(10).map { $0 }
    }

    var topLosers: [Coin] {
        coins.sorted(by: { $0.priceChangePercentage24h < $1.priceChangePercentage24h }).prefix(10).map { $0 }
    }

    var filteredCoins: [Coin] {
        if searchText.isEmpty {
            return coins
        } else {
            return coins.filter { $0.name.contains(searchText) || $0.symbol.contains(searchText) }
        }
    }
}

