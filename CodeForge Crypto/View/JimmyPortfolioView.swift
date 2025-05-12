import SwiftUI

struct JimmyPortfolioView: View {
    @EnvironmentObject var viewModel: PortfolioViewModel
    @StateObject private var marketViewModel = MarketViewModel()
    @State private var selectedTab = 0
    @State private var totalInvested: Double = 0
    @State private var totalValue: Double = 0
    
    var totalProfit: Double {
        totalValue - totalInvested
    }
    
    var profitPercentage: Double {
        if totalInvested > 0 {
            return (totalProfit / totalInvested) * 100
        }
        return 0
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Portfolio Header with icon
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    
                    Text("Portfolio")
                        .font(.largeTitle)
                        .bold()
                }
                .padding()
                
                // Balance Display with color
                VStack(spacing: 10) {
                    Text("Total Balance")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.balanceText)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("AUD")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Profit Section
                VStack(spacing: 10) {
                    Text("Total Profit/Loss")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("$\(String(format: "%.2f", totalProfit))")
                            .font(.title2)
                            .bold()
                            .foregroundColor(totalProfit >= 0 ? .green : .red)
                        
                        Text("(\(String(format: "%.1f", profitPercentage))%)")
                            .font(.headline)
                            .foregroundColor(totalProfit >= 0 ? .green : .red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(totalProfit >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Tab Selector with color
                Picker("", selection: $selectedTab) {
                    Text("Holdings").tag(0)
                    Text("Trade History").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on tab
                if selectedTab == 0 {
                    // Holdings
                    if viewModel.holdings.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "tray")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No holdings yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Start trading to see your crypto here!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(50)
                    } else {
                        List(viewModel.holdings, id: \.id) { holding in
                            HStack {
                                // Icon with proper fallback
                                Group {
                                    if let coin = getCoinData(for: holding.coinID) {
                                        AsyncImage(url: URL(string: coin.image)) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 40, height: 40)
                                            case .failure(_), .empty:
                                                // Fallback to initials
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: 40, height: 40)
                                                    Text(coin.symbol.prefix(2).uppercased())
                                                        .font(.caption)
                                                        .bold()
                                                        .foregroundColor(.primary)
                                                }
                                            @unknown default:
                                                ProgressView()
                                                    .frame(width: 40, height: 40)
                                            }
                                        }
                                    } else {
                                        // Fallback when no coin data
                                        ZStack {
                                            Circle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Text(holding.coinID.prefix(2).uppercased())
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(holding.coinName)
                                        .font(.headline)
                                    Text("\(String(format: "%.4f", holding.amount)) coins")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Calculate current value and profit
                                if let coin = getCoinData(for: holding.coinID) {
                                    let currentValue = holding.amount * coin.currentPrice
                                    let averagePrice = calculateAveragePrice(for: holding.coinID)
                                    let profit = currentValue - (holding.amount * averagePrice)
                                    
                                    VStack(alignment: .trailing) {
                                        Text("$\(String(format: "%.2f", currentValue))")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                        Text("\(profit >= 0 ? "+" : "")\(String(format: "%.2f", profit))")
                                            .font(.caption)
                                            .foregroundColor(profit >= 0 ? .green : .red)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                } else {
                    // Trade History
                    if viewModel.tradeHistory.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No trades yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Your trading history will appear here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(50)
                    } else {
                        List(viewModel.tradeHistory, id: \.id) { trade in
                            HStack(spacing: 15) {
                                // Trade type icon with color
                                ZStack {
                                    Circle()
                                        .fill(trade.type == .buy ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: trade.type == .buy ? "arrow.down" : "arrow.up")
                                        .foregroundColor(trade.type == .buy ? .green : .red)
                                        .font(.title3)
                                        .bold()
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(trade.type == .buy ? "Bought" : "Sold")
                                            .font(.headline)
                                            .foregroundColor(trade.type == .buy ? .green : .red)
                                        Text(trade.coinSymbol.uppercased())
                                            .font(.headline)
                                    }
                                    Text("\(String(format: "%.4f", trade.amount)) @ $\(String(format: "%.2f", trade.currentPrice))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("$\(String(format: "%.2f", trade.amount * trade.currentPrice))")
                                        .font(.headline)
                                        .bold()
                                    Text(trade.date.formatted(.dateTime.hour().minute()))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: RechargeView().environmentObject(viewModel)) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Recharge")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .task {
            // Fetch live coin data when view appears
            await marketViewModel.fetchCoins()
        }
        .onAppear {
            calculateTotalProfit()
            
            // Listen for notification to show trades tab
            NotificationCenter.default.addObserver(
                forName: Notification.Name("ShowTradesTab"),
                object: nil,
                queue: .main
            ) { _ in
                selectedTab = 1
            }
        }
    }
    
    // Get coin data from live API or fallback to static
    func getCoinData(for coinID: String) -> Coin? {
        // First try to get from live API data
        if let coin = marketViewModel.coins.first(where: { $0.id == coinID }) {
            return coin
        }
        // Fallback to static data if not found
        return StaticData.first(where: { $0.id == coinID })
    }
    
    // Simple function to calculate average price for a coin
    func calculateAveragePrice(for coinID: String) -> Double {
        let buyTrades = viewModel.tradeHistory.filter { $0.coinID == coinID && $0.type == .buy }
        
        if buyTrades.isEmpty {
            return 0
        }
        
        var totalSpent: Double = 0
        var totalAmount: Double = 0
        
        for trade in buyTrades {
            totalSpent += trade.amount * trade.currentPrice
            totalAmount += trade.amount
        }
        
        return totalAmount > 0 ? totalSpent / totalAmount : 0
    }
    
    // Calculate total profit/loss
    func calculateTotalProfit() {
        var invested: Double = 0
        var currentValue: Double = 0
        
        // Calculate total invested from buy trades
        for trade in viewModel.tradeHistory {
            if trade.type == .buy {
                invested += trade.amount * trade.currentPrice
            } else {
                // For sells, reduce the invested amount
                invested -= trade.amount * trade.currentPrice
            }
        }
        
        // Calculate current value from holdings using live data
        for holding in viewModel.holdings {
            if let coin = getCoinData(for: holding.coinID) {
                currentValue += holding.amount * coin.currentPrice
            }
        }
        
        totalInvested = invested
        totalValue = currentValue
    }
}

#Preview {
    NavigationStack {
        JimmyPortfolioView()
            .environmentObject(PortfolioViewModel())
    }
}
