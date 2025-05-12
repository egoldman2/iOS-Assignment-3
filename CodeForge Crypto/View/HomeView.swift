import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MarketViewModel()
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @State private var selectedTab = 0
    @State private var selectedCategory = "Trending"
    @State private var sortBy = ""
    @State private var sortDescending = true

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                VStack {
                    // Header
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        Text("Crypto Market")
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding()
                    
                    // Featured Coin
                    if let featuredCoin = viewModel.coins.first {
                        VStack(spacing: 10) {
                            Text("Featured Coin")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                AsyncImage(url: URL(string: featuredCoin.image)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                
                                VStack(alignment: .leading) {
                                    Text(featuredCoin.name)
                                        .font(.title2)
                                        .bold()
                                    Text(featuredCoin.symbol.uppercased())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("$\(String(format: "%.2f", featuredCoin.currentPrice))")
                                        .font(.title3)
                                        .bold()
                                    HStack {
                                        Image(systemName: featuredCoin.priceChangePercentage24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                                            .font(.caption)
                                        Text("\(String(format: "%.2f", abs(featuredCoin.priceChangePercentage24h)))%")
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(featuredCoin.priceChangePercentage24h >= 0 ? .green : .red)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Category Selector
                    HStack(spacing: 12) {
                        ForEach(["Trending", "Top Gainers", "Top Losers"], id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                sortBy = "" // Reset sort when changing category
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedCategory == category ? .blue : .primary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Sort Options
                    HStack {
                        Text("Market Overview")
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack(spacing: 10) {
                            Button(action: {
                                if sortBy == "price" {
                                    sortDescending.toggle()
                                } else {
                                    sortBy = "price"
                                    sortDescending = true
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text("Price")
                                        .font(.caption)
                                    if sortBy == "price" {
                                        Image(systemName: sortDescending ? "chevron.down" : "chevron.up")
                                            .font(.caption2)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(sortBy == "price" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .foregroundColor(sortBy == "price" ? .blue : .primary)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                if sortBy == "change" {
                                    sortDescending.toggle()
                                } else {
                                    sortBy = "change"
                                    sortDescending = true
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text("24h %")
                                        .font(.caption)
                                    if sortBy == "change" {
                                        Image(systemName: sortDescending ? "chevron.down" : "chevron.up")
                                            .font(.caption2)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(sortBy == "change" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .foregroundColor(sortBy == "change" ? .blue : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Coin List
                    if viewModel.coins.isEmpty {
                        Spacer()
                        ProgressView("Loading...")
                            .padding()
                        Spacer()
                    } else {
                        List(displayedCoins) { coin in
                            NavigationLink(destination: CoinDetailView(viewModel: CoinDetailViewModel(coin: coin))
                                .environmentObject(portfolioVM)) {
                                HStack {
                                    // Coin image without rank number
                                    AsyncImage(url: URL(string: coin.image)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray.opacity(0.1))
                                            .overlay(
                                                ProgressView()
                                            )
                                    }
                                    .frame(width: 40, height: 40)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(coin.name)
                                            .font(.headline)
                                        Text(coin.symbol.uppercased())
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("$\(String(format: "%.2f", coin.currentPrice))")
                                            .font(.headline)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: coin.priceChangePercentage24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                                                .font(.caption2)
                                            Text("\(String(format: "%.2f", abs(coin.priceChangePercentage24h)))%")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(coin.priceChangePercentage24h >= 0 ? .green : .red)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .task {
                    // Always fetch fresh data when view appears
                    viewModel.clearCache()
                    await viewModel.fetchCoins()
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)

            NavigationStack {
                JimmyPortfolioView()
                    .environmentObject(portfolioVM)
            }
            .tabItem {
                Image(systemName: "briefcase.fill")
                Text("Portfolio")
            }
            .tag(1)

            NavigationStack {
                ProfileView()
                    .environmentObject(portfolioVM)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(2)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // Listen for going home
            NotificationCenter.default.addObserver(
                forName: Notification.Name("GoToHome"),
                object: nil,
                queue: .main
            ) { _ in
                selectedTab = 0
            }
            
            // If we have too few coins, fetch more
            if viewModel.coins.count <= StaticData.count {
                Task {
                    viewModel.clearCache()
                    await viewModel.fetchCoins()
                }
            }
        }
    }
    
    private var displayedCoins: [Coin] {
        var coins: [Coin] = []
        
        // Filter by category
        switch selectedCategory {
        case "Trending":
            coins = viewModel.coins.sorted { $0.marketCap > $1.marketCap }.prefix(10).map { $0 }
        case "Top Gainers":
            coins = viewModel.coins.sorted { $0.priceChangePercentage24h > $1.priceChangePercentage24h }.prefix(10).map { $0 }
        case "Top Losers":
            coins = viewModel.coins.sorted { $0.priceChangePercentage24h < $1.priceChangePercentage24h }.prefix(10).map { $0 }
        default:
            coins = viewModel.coins
        }
        
        // Apply sorting
        switch sortBy {
        case "price":
            return coins.sorted { sortDescending ? $0.currentPrice > $1.currentPrice : $0.currentPrice < $1.currentPrice }
        case "change":
            return coins.sorted { sortDescending ? $0.priceChangePercentage24h > $1.priceChangePercentage24h : $0.priceChangePercentage24h < $1.priceChangePercentage24h }
        default:
            return coins
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(PortfolioViewModel())
}
