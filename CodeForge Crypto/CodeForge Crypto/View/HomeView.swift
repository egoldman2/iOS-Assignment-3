import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MarketViewModel()
    @State private var selectedCategory = "Trending"
    @State private var isDescending = true
    @State private var sortKey = "marketCap"

    var body: some View {
            VStack(spacing: 16) {
                // Featured Coin
                if let featuredCoin = viewModel.trendingCoins.first {
                    VStack(alignment: .leading) {
                        Text("🔥 Featured Coin")
                            .font(.headline)
                        HStack {
                            AsyncImage(url: URL(string: featuredCoin.image)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(featuredCoin.name)
                                    .font(.title2).bold()
                                Text("$\(String(format: "%.2f", featuredCoin.currentPrice))")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                // Category Buttons
                HStack {
                    ForEach(["Trending", "Top Gainers", "Top Losers"], id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .fontWeight(.medium)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(selectedCategory == category ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)

                // Table Header
                HStack {
                    Text("Coin")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("Price") {
                        sortKey = "price"
                        isDescending.toggle()
                        viewModel.sortCoins(by: sortKey, reverse: !isDescending)
                    }
                    .frame(width: 80, alignment: .trailing)

                    Button("Change %") {
                        sortKey = "change24h"
                        isDescending.toggle()
                        viewModel.sortCoins(by: sortKey, reverse: !isDescending)
                    }
                    .frame(width: 80, alignment: .trailing)
                }
                .font(.headline)
                .padding(.horizontal)

                // Coin List Table with Navigation
                List {
                    ForEach(displayedCoins.prefix(10)) { coin in
                        NavigationLink(destination: CoinDetailView(viewModel: CoinDetailViewModel(coin: coin))) {
                            HStack {
                                Text(coin.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("$\(String(format: "%.2f", coin.currentPrice))")
                                    .frame(width: 80, alignment: .trailing)

                                Text("\(String(format: "%.2f", coin.priceChangePercentage24h))%")
                                    .foregroundColor(coin.priceChangePercentage24h >= 0 ? .green : .red)
                                    .frame(width: 80, alignment: .trailing)
                            }
                        }
                    }
                }
                .listStyle(.plain)

                Spacer()
            }
            .padding()
            .navigationTitle("Crypto Market")
            .task {
                await viewModel.fetchCoins()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                    }
                }
            }

        
        
    }

    // Category selection logic
    private var displayedCoins: [Coin] {
        switch selectedCategory {
        case "Top Gainers":
            return viewModel.topGainers
        case "Top Losers":
            return viewModel.topLosers
        default:
            return viewModel.trendingCoins
        }
    }
}


#Preview {
    NavigationStack {
        HomeView()
    }
}
