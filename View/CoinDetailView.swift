import SwiftUI
import Charts

struct CoinDetailView: View {
    @StateObject var viewModel: CoinDetailViewModel
    @State private var selectedRange: ChartRange = .week
    @State private var isLoading = true
    @State private var showTrade = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

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
                        Chart(viewModel.coinHistoryChartData) { point in
                            LineMark(
                                x: .value("Date", point.time),
                                y: .value("Price", point.price)
                            )
                        }
                        .frame(height: 300)
                    }
                }

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

 
        .safeAreaInset(edge: .bottom) {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                Button(action: {
                    showTrade = true
                }) {
                    Text("Trade")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                }
            }
            .frame(height: 80)
        }

        // profile button
        .navigationTitle(viewModel.coin.symbol.uppercased())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showTrade) {
            TradeView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            }
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

