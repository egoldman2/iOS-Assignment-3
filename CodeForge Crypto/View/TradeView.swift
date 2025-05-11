import SwiftUI

struct TradeView: View {
    let coin: Coin
    let type: TradeType

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var portfolioVM: PortfolioViewModel

    @State private var amountText: String = ""
    @State private var goToPortfolio = false
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            Text("\(type == .buy ? "Buy" : "Sell") \(coin.name)")
                .font(.title)
                .bold()

            Text("Current Price: $\(String(format: "%.2f", coin.currentPrice))")

            TextField("Enter amount", text: $amountText)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Confirm \(type == .buy ? "Buy" : "Sell")") {
                confirmTrade()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(type == .buy ? Color.green : Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .navigationTitle("Trade")
        .navigationDestination(isPresented: $goToPortfolio) {
            JimmyPortfolioView()
                .environmentObject(portfolioVM)
        }
        .alert("Trade Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Insufficient balance, no holdings, or invalid input.")
        }
    }

    private func confirmTrade() {
        guard let amount = Double(amountText), amount > 0 else {
            print("invalid amount：\(amountText)")
            showError = true
            return
        }

        let success = portfolioVM.trade(coin: coin, type: type, amount: amount)
        if success {
            print("success")
            goToPortfolio = true
        } else {
            print("fail")
            showError = true
        }
    }
}

#Preview {
    TradeView(coin: StaticData[0], type: .buy)
        .environmentObject(PortfolioViewModel())
}

