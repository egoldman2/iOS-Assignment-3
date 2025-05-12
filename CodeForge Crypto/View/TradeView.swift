import SwiftUI
import Charts

struct TradeView: View {
    let coin: Coin
    let type: TradeType

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var portfolioVM: PortfolioViewModel

    @State private var amountText: String = ""
    @State private var valueText: String = ""
    @State private var inputMode: InputMode = .amount
    @State private var goToPortfolio = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showPercentageButtons = true
    
    enum InputMode: String, CaseIterable {
        case amount = "Amount"
        case value = "Value (AUD)"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            // Coin Icon and Name
                            AsyncImage(url: URL(string: coin.image)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                case .failure(_):
                                    Image(systemName: "exclamationmark.circle")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                default:
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                }
                            }
                            
                            Text("\(type == .buy ? "Buy" : "Sell") \(coin.name)")
                                .font(.title)
                                .bold()
                            
                            Text("$\(String(format: "%.2f", coin.currentPrice)) AUD")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            // Price Change Indicator
                            HStack(spacing: 4) {
                                Image(systemName: coin.priceChangePercentage24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                                    .font(.caption)
                                Text("\(String(format: "%.2f", abs(coin.priceChangePercentage24h)))%")
                                    .font(.caption)
                            }
                            .foregroundColor(coin.priceChangePercentage24h >= 0 ? .green : .red)
                        }
                        .padding(.top)
                        
                        // Market Stats
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("24h High")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("$\(String(format: "%.2f", coin.high24h))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .center, spacing: 4) {
                                Text("24h Volume")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("$\(formatLargeNumber(coin.totalVolume))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("24h Low")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("$\(String(format: "%.2f", coin.low24h))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Balance/Holdings Info
                        if type == .buy {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Available Balance")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(portfolioVM.balanceText) AUD")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        } else {
                            let holding = portfolioVM.holdings.first(where: { $0.coinID == coin.id })
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Available to Sell")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.6f", holding?.amount ?? 0)) \(coin.symbol.uppercased())")
                                    .font(.headline)
                                Text("≈ $\(String(format: "%.2f", (holding?.amount ?? 0) * coin.currentPrice)) AUD")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        // Input Mode Selector
                        Picker("Input Mode", selection: $inputMode) {
                            ForEach(InputMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Input Fields
                        VStack(spacing: 16) {
                            if inputMode == .amount {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Enter amount of \(coin.symbol.uppercased())")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0.0", text: $amountText)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: amountText) { _, newValue in
                                            updateValueFromAmount(newValue)
                                        }
                                    
                                    if !valueText.isEmpty {
                                        Text("≈ $\(valueText) AUD")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Enter value in AUD")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("$0.00", text: $valueText)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: valueText) { _, newValue in
                                            updateAmountFromValue(newValue)
                                        }
                                    
                                    if !amountText.isEmpty {
                                        Text("≈ \(amountText) \(coin.symbol.uppercased())")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Quick Percentage Buttons
                        if showPercentageButtons {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quick Select")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 10) {
                                    ForEach([25, 50, 75, 100], id: \.self) { percentage in
                                        Button(action: {
                                            selectPercentage(percentage)
                                        }) {
                                            Text("\(percentage)%")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 8)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Trade Summary
                        if let amount = Double(amountText), amount > 0 {
                            VStack(spacing: 12) {
                                Divider()
                                
                                HStack {
                                    Text("Amount:")
                                    Spacer()
                                    Text("\(String(format: "%.6f", amount)) \(coin.symbol.uppercased())")
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Total \(type == .buy ? "Cost" : "Value"):")
                                    Spacer()
                                    Text("$\(String(format: "%.2f", amount * coin.currentPrice)) AUD")
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Price per coin:")
                                    Spacer()
                                    Text("$\(String(format: "%.2f", coin.currentPrice)) AUD")
                                        .fontWeight(.medium)
                                }
                                
                                if type == .buy {
                                    HStack {
                                        Text("Balance after:")
                                        Spacer()
                                        Text("$\(String(format: "%.2f", portfolioVM.portfolio.balance - (amount * coin.currentPrice))) AUD")
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Divider()
                            }
                            .padding(.horizontal)
                            .font(.subheadline)
                        }
                        
                        // Add some padding at the bottom
                        Spacer(minLength: 100)
                    }
                }
                
                // Bottom Confirm Button
                VStack {
                    Spacer()
                    
                    Button(action: confirmTrade) {
                        HStack {
                            Image(systemName: type == .buy ? "plus.circle.fill" : "minus.circle.fill")
                            Text("Confirm \(type == .buy ? "Buy" : "Sell")")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValidInput ? (type == .buy ? Color.green : Color.red) : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!isValidInput)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Trade")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $goToPortfolio) {
                JimmyPortfolioView()
                    .environmentObject(portfolioVM)
            }
            .alert("Trade Failed", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isValidInput: Bool {
        guard let amount = Double(amountText), amount > 0 else { return false }
        
        if type == .sell {
            let currentHolding = portfolioVM.holdings.first(where: { $0.coinID == coin.id })
            return amount <= (currentHolding?.amount ?? 0)
        }
        
        if type == .buy {
            let totalCost = amount * coin.currentPrice
            return totalCost <= portfolioVM.portfolio.balance
        }
        
        return true
    }
    
    private func formatLargeNumber(_ number: Double) -> String {
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
    
    private func selectPercentage(_ percentage: Int) {
        if type == .buy {
            // For buying, calculate based on available balance
            let maxValue = portfolioVM.portfolio.balance
            let selectedValue = maxValue * Double(percentage) / 100.0
            valueText = String(format: "%.2f", selectedValue)
            updateAmountFromValue(valueText)
        } else {
            // For selling, calculate based on holdings
            let holding = portfolioVM.holdings.first(where: { $0.coinID == coin.id })
            let maxAmount = holding?.amount ?? 0
            let selectedAmount = maxAmount * Double(percentage) / 100.0
            amountText = String(format: "%.6f", selectedAmount)
            updateValueFromAmount(amountText)
        }
    }
    
    private func updateValueFromAmount(_ amountString: String) {
        guard !amountString.isEmpty,
              let amount = Double(amountString) else {
            valueText = ""
            return
        }
        
        let value = amount * coin.currentPrice
        valueText = String(format: "%.2f", value)
    }
    
    private func updateAmountFromValue(_ valueString: String) {
        guard !valueString.isEmpty,
              let value = Double(valueString),
              coin.currentPrice > 0 else {
            amountText = ""
            return
        }
        
        let amount = value / coin.currentPrice
        amountText = String(format: "%.6f", amount)
    }

    private func confirmTrade() {
        guard let amount = Double(amountText), amount > 0 else {
            errorMessage = "Invalid amount entered"
            showError = true
            return
        }
        
        // Additional validation for sell orders
        if type == .sell {
            let currentHolding = portfolioVM.holdings.first(where: { $0.coinID == coin.id })
            let availableAmount = currentHolding?.amount ?? 0
            
            if amount > availableAmount {
                errorMessage = "Insufficient holdings. You have \(String(format: "%.6f", availableAmount)) \(coin.symbol.uppercased())"
                showError = true
                return
            }
        }
        
        // Additional validation for buy orders
        if type == .buy {
            let totalCost = amount * coin.currentPrice
            if totalCost > portfolioVM.portfolio.balance {
                errorMessage = "Insufficient balance. You need $\(String(format: "%.2f", totalCost)) AUD but have \(portfolioVM.balanceText)"
                showError = true
                return
            }
        }

        let success = portfolioVM.trade(coin: coin, type: type, amount: amount)
        if success {
            print("Trade successful")
            goToPortfolio = true
        } else {
            errorMessage = "Trade failed. Please try again."
            print("Trade failed")
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        TradeView(coin: StaticData[0], type: .buy)
            .environmentObject(PortfolioViewModel())
    }
}
