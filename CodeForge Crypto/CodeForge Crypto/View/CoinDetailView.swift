import SwiftUI
import Charts

struct CoinDetailView: View {
    @ObservedObject private var holdingsManager = HoldingsManager.shared
    @StateObject var viewModel: CoinDetailViewModel
    @State private var selectedRange: ChartRange = .week
    @State private var isLoading = true
    @State private var showTrade = false

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    AsyncImage(url: URL(string: viewModel.coin.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        case .failure:
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    Text(viewModel.coin.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                }
                
                
                // allow the user to select the date for data
                HStack(spacing: 12) {
                    ForEach(ChartRange.allCases, id: \.self) { range in
                        Button(action: {
                            selectedRange = range
                            isLoading = true
                            Task {
                                await viewModel.loadChartData(for: range)
                                isLoading = false
                            }
                        }) {
                            Text(range.label)
                                .fontWeight(.medium)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(selectedRange == range ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }

                // history chart
                Group {
                    if isLoading {
                        ProgressView("Loading chart...")
                            .frame(height: 300)
                    } else if viewModel.coinHistoryChartData.isEmpty {
                        Text("No chart data available.")
                            .foregroundColor(.gray)
                            .frame(height: 300)
                    } else {
                        let minPrice = viewModel.coinHistoryChartData.map(\.price).min() ?? 0
                        let maxPrice = viewModel.coinHistoryChartData.map(\.price).max() ?? 1

                        Chart(viewModel.coinHistoryChartData) { point in
                            LineMark(
                                x: .value("Date", point.time),
                                y: .value("Price", point.price)
                            )
                        }
                        .chartYScale(domain: minPrice...maxPrice)
                        .frame(height: 300)
                    }
                }
                
                let amountHeld = holdingsManager.amount(for: viewModel.coin.id)
                let totalValue = amountHeld * viewModel.coin.currentPrice

                HStack {
                    Text("Currently held:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)

                    Text("Value:")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.headline)
                }
                .padding(.horizontal)

                HStack {
                    Text(String(format: "%.4f", amountHeld))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(String(format: "$%.2f", totalValue))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button(action: {
                        showTrade = true
                    }) {
                        Text("Buy")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        showTrade = true
                    }) {
                        Text("Sell")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                // status
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status")
                        .font(.headline)
                        .padding(.bottom, 4)

                    Group {
                        Text("Current Price: $\(formatted(viewModel.coin.currentPrice))")
                        Text("Market Cap: $\(formatted(viewModel.coin.marketCap))")
                        Text("Market Cap Change (24h): $\(formatted(viewModel.coin.marketCapChange24h))")
                        Text("Market Cap Change % (24h): \(formatted(viewModel.coin.marketCapChangePercentage24h))%")
                        Text("Total Volume (24h): $\(formatted(viewModel.coin.totalVolume))")
                        Text("24h High: $\(formatted(viewModel.coin.high24h))")
                        Text("24h Low: $\(formatted(viewModel.coin.low24h))")
                        Text("Price Change (24h): $\(formatted(viewModel.coin.priceChange24h))")
                        Text("Price Change % (24h): \(formatted(viewModel.coin.priceChangePercentage24h))%")
                        Text("Circulating Supply: \(formatted(viewModel.coin.circulatingSupply))")
                        Text("Total Supply: \(formatted(viewModel.coin.totalSupply))")
                        Text("Max Supply: \(formatted(viewModel.coin.maxSupply ?? 0))")
                        Text("All-Time High: $\(formatted(viewModel.coin.ath))")
                        Text("All-Time Low: $\(formatted(viewModel.coin.atl))")
                    }
                    .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.bottom, 100)
            }
            .padding(.horizontal)
        }

        
        .onAppear {
            Task {
                isLoading = true
                await viewModel.loadChartData(for: selectedRange)
                isLoading = false
            }
        }
    }

    func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "-"
    }
}

#Preview {
    CoinDetailView(viewModel: CoinDetailViewModel(coin: StaticData[0]))
}
