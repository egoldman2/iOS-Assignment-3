import SwiftUI
import Charts

struct CoinDetailView: View {
    @StateObject var viewModel: CoinDetailViewModel
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @State private var selectedRange: ChartRange = .week
    @State private var isLoading = true
    @State private var tradeType: TradeType? = nil
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
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
                }
                .padding()

                // Date range buttons
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
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedRange == range ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedRange == range ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }

                // Chart
                if isLoading {
                    ProgressView("Loading...")
                        .frame(height: 250)
                } else if viewModel.coinHistoryChartData.isEmpty {
                    Text("No chart data")
                        .foregroundColor(.secondary)
                        .frame(height: 250)
                } else {
                    Chart(viewModel.coinHistoryChartData) { point in
                        LineMark(
                            x: .value("Date", point.time),
                            y: .value("Price", point.price)
                        )
                    }
                    .frame(height: 250)
                    .padding(.horizontal)
                }

                // Holdings section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Holdings")
                        .font(.headline)
                        .padding(.horizontal)

                    let holding = portfolioVM.holdings.first(where: { $0.coinID == viewModel.coin.id })
                    let amount = holding?.amount ?? 0
                    let value = amount * viewModel.coin.currentPrice

                    HStack {
                        Text("Amount: \(amount, specifier: "%.4f")")
                        Spacer()
                        Text("Value: $\(value, specifier: "%.2f") AUD")
                    }
                    .padding(.horizontal)
                    .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                // Buy & Sell buttons
                HStack(spacing: 20) {
                    Button("Buy") {
                        tradeType = .buy
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Sell") {
                        tradeType = .sell
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                // Simple Status section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Market Stats")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        // Current Price
                        HStack {
                            Text("Current Price:")
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.coin.currentPrice)) AUD")
                                .fontWeight(.semibold)
                        }
                        
                        // 24h Change
                        HStack {
                            Text("24h Change:")
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.coin.priceChangePercentage24h >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.caption)
                                Text("\(String(format: "%.2f", abs(viewModel.coin.priceChangePercentage24h)))%")
                            }
                            .foregroundColor(viewModel.coin.priceChangePercentage24h >= 0 ? .green : .red)
                        }
                        
                        // Market Cap
                        HStack {
                            Text("Market Cap:")
                            Spacer()
                            Text("$\(formatNumber(viewModel.coin.marketCap))")
                        }
                        
                        // 24h Volume
                        HStack {
                            Text("24h Volume:")
                            Spacer()
                            Text("$\(formatNumber(viewModel.coin.totalVolume))")
                        }
                        
                        Divider()
                        
                        // High/Low
                        HStack {
                            Text("24h High:")
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.coin.high24h))")
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("24h Low:")
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.coin.low24h))")
                                .foregroundColor(.red)
                        }
                        
                        Divider()
                        
                        // Supply
                        HStack {
                            Text("Circulating Supply:")
                            Spacer()
                            Text("\(formatNumber(viewModel.coin.circulatingSupply))")
                        }
                        
                        HStack {
                            Text("Total Supply:")
                            Spacer()
                            Text("\(formatNumber(viewModel.coin.totalSupply))")
                        }
                        
                        if let maxSupply = viewModel.coin.maxSupply {
                            HStack {
                                Text("Max Supply:")
                                Spacer()
                                Text("\(formatNumber(maxSupply))")
                            }
                        }
                        
                        Divider()
                        
                        // All-time high/low
                        HStack {
                            Text("All-Time High:")
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.coin.ath))")
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("All-Time Low:")
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.coin.atl))")
                                .foregroundColor(.red)
                        }
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            isLoading = true
            await viewModel.loadChartData(for: selectedRange)
            isLoading = false
        }
        .navigationDestination(isPresented: Binding<Bool>(
            get: { tradeType != nil },
            set: { if !$0 { tradeType = nil } }
        )) {
            if let tradeType = tradeType {
                TradeView(coin: viewModel.coin, type: tradeType)
                    .environmentObject(portfolioVM)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GoToHome"))) { _ in
            dismiss()
        }
    }

    // Simple number formatter
    private func formatNumber(_ number: Double) -> String {
        if number >= 1_000_000_000 {
            return String(format: "%.1fB", number / 1_000_000_000)
        } else if number >= 1_000_000 {
            return String(format: "%.1fM", number / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", number / 1_000)
        } else {
            return String(format: "%.0f", number)
        }
    }
}

#Preview {
    CoinDetailView(viewModel: CoinDetailViewModel(coin: StaticData[0]))
        .environmentObject(PortfolioViewModel())
}
