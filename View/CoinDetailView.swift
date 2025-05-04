import SwiftUI
import Charts

struct CoinDetailView: View {
    @StateObject var viewModel: CoinDetailViewModel
    @State private var selectedRange: ChartRange = .week
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(viewModel.coin.name)
                .font(.largeTitle)
                .bold()

            Text("$\(String(format: "%.2f", viewModel.coin.currentPrice))")
                .font(.title)

            Text("\(String(format: "%.2f", viewModel.coin.priceChangePercentage24h))%")
                .foregroundColor(viewModel.coin.priceChangePercentage24h >= 0 ? .green : .red)

            // Range Selector
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

            // Chart or Loading/Error
            Group {
                if isLoading {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView("Loading chart...")
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(height: 250)
                } else if viewModel.coinHistoryChartData.isEmpty {
                    Text("No chart data available.")
                        .foregroundColor(.gray)
                        .frame(height: 250)
                } else {
                    Chart(viewModel.coinHistoryChartData) { point in
                        LineMark(
                            x: .value("Date", point.time),
                            y: .value("Price", point.price)
                        )
                    }
                    .frame(height: 250)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle(viewModel.coin.symbol.uppercased())
        .onAppear {
            Task {
                isLoading = true
                await viewModel.loadChartData(for: selectedRange)
                isLoading = false
            }
        }
    }
}

