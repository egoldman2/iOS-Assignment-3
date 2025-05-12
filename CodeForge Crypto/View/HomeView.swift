import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MarketViewModel()
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @State private var selectedCategory = "Trending"
    @State private var priceSortDescending = true
    @State private var changeSortDescending = true
    @State private var sortKey = ""

    var body: some View {
        TabView {
            NavigationStack {
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
                                    Text("$\(String(format: "%.2f", featuredCoin.currentPrice)) AUD")
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
                                sortKey = "" // Reset sort when switching categories
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
                        
                        Button(action: {
                            if sortKey == "price" {
                                priceSortDescending.toggle()
                            } else {
                                sortKey = "price"
                                priceSortDescending = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("Price")
                                Text("(AUD)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if sortKey == "price" {
                                    Image(systemName: priceSortDescending ? "chevron.down" : "chevron.up")
                                        .font(.caption)
                                }
                            }
                        }
                        .frame(width: 100, alignment: .trailing)
                        
                        Button(action: {
                            if sortKey == "change" {
                                changeSortDescending.toggle()
                            } else {
                                sortKey = "change"
                                changeSortDescending = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("Change %")
                                if sortKey == "change" {
                                    Image(systemName: changeSortDescending ? "chevron.down" : "chevron.up")
                                        .font(.caption)
                                }
                            }
                        }
                        .frame(width: 100, alignment: .trailing)
                    }
                    .font(.headline)
                    .padding(.horizontal)
                    
                    // Coin List Table with Navigation
                    List {
                        ForEach(sortedCoins.prefix(10)) { coin in
                            NavigationLink(destination: CoinDetailView(viewModel: CoinDetailViewModel(coin: coin))
                                .environmentObject(portfolioVM)) {
                                    HStack {
                                        Text(coin.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("$\(String(format: "%.2f", coin.currentPrice))")
                                            .frame(width: 100, alignment: .trailing)
                                        
                                        Text("\(String(format: "%.2f", coin.priceChangePercentage24h))%")
                                            .foregroundColor(coin.priceChangePercentage24h >= 0 ? .green : .red)
                                            .frame(width: 100, alignment: .trailing)
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
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            NavigationStack {
                JimmyPortfolioView()
                    .environmentObject(portfolioVM)
            }
            .tabItem {
                Image(systemName: "briefcase.fill")
                Text("Portfolio")
            }

            NavigationStack {
                ProfileView()
                    .environmentObject(portfolioVM)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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
    
    // Sorted coins based on current sort key
    private var sortedCoins: [Coin] {
        let coins = displayedCoins
        
        switch sortKey {
        case "price":
            return coins.sorted { priceSortDescending ? $0.currentPrice > $1.currentPrice : $0.currentPrice < $1.currentPrice }
        case "change":
            return coins.sorted { changeSortDescending ? $0.priceChangePercentage24h > $1.priceChangePercentage24h : $0.priceChangePercentage24h < $1.priceChangePercentage24h }
        default:
            return coins // Return unsorted for default view
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(PortfolioViewModel())
}
