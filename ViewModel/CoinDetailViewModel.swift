
import Foundation

@MainActor
class CoinDetailViewModel: ObservableObject {
    @Published var coin: Coin
    @Published var coinHistoryChartData: [CoinHistoryChart] = []

    //store cache becuase we using free api request,the time to request is limited.
    private var chartDataCache: [String: [Int: [CoinHistoryChart]]] = [:]

    init(coin: Coin) {
        self.coin = coin
    }

    //before loading data ,checking the cache first
    func loadChartData(for range: ChartRange) async {
        let coinId = coin.id
        let days = range.rawValue

        if let cachedForCoin = chartDataCache[coinId],
           let cachedData = cachedForCoin[days] {
            print("Loaded chart data from cache for \(coinId), \(range.label)")
            self.coinHistoryChartData = cachedData
            return
        }

        print("No cache. Fetching chart for \(coinId), \(range.label)")
        await fetchChartData(range: range)

        // Save result in cache after fetching
        chartDataCache[coinId, default: [:]][days] = self.coinHistoryChartData
    }

    // Fetch chart data from  API based on the selected day,the day has defined a emun in model
    func fetchChartData(range: ChartRange) async {
        let from = range.fromTimestamp
        let to = range.toTimestamp

        guard from < to else {
            handle(error: .custom(message: "Invalid time range: from > to"))
            return
        }

        let urlString = "https://api.coingecko.com/api/v3/coins/\(coin.id)/market_chart/range?vs_currency=usd&from=\(from)&to=\(to)"
        print("Fetching \(range.label) data from: \(urlString)")

        guard let url = URL(string: urlString) else {
            handle(error: .invalidResponse)
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
//check if the http response and print out the respons
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let json = String(data: data, encoding: .utf8) {
                print("Raw response (truncated): \(json.prefix(500))")
            }

            let decoded = try JSONDecoder().decode(MarketChartResponse.self, from: data)

            let parsedData = decoded.prices.compactMap { item -> CoinHistoryChart? in
                if item.count >= 2 {
                    let time = Date(timeIntervalSince1970: item[0] / 1000)
                    let price = item[1]
                    return CoinHistoryChart(time: time, price: price)
                } else {
                    print("Invalid item: \(item)")
                    return nil
                }
            }
// transefer the return data to the model structure which we defined.
            self.coinHistoryChartData = parsedData
//if the return data is empty switch to static data.
            if parsedData.isEmpty {
                print("No chart data received. Using static fallback.")
                self.coinHistoryChartData = StaticChartPoints
            } else {
                print("Loaded \(parsedData.count) chart points")
            }

        } catch is DecodingError {
            print("Decoding error")
            handle(error: .decodingError)
        } catch {
            print("Other error: \(error.localizedDescription)")
            handle(error: .apiFailure)
        }
    }

    // Handle error and if fetch data fail switch to static data
    private func handle(error: AppError) {
        print("Chart fetch error: \(error.localizedDescription)")
        self.coinHistoryChartData = StaticChartPoints
    }

    func clearCache() {
        chartDataCache.removeAll()
        print("Chart cache cleared")
    }


    private struct MarketChartResponse: Codable {
        let prices: [[Double]]
    }
}
