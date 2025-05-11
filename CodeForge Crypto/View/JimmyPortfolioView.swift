import SwiftUI

struct JimmyPortfolioView: View {
    @EnvironmentObject var viewModel: PortfolioViewModel
    @State private var showRecharge = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Balance: \(viewModel.balanceText)")
                        .font(.title2)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Holdings")
                        .font(.headline)
                    Text("Your Current Holdings")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if viewModel.holdings.isEmpty {
                        Text("No holdings yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.holdings, id: \.id) { holding in
                            HStack {
                                Text(holding.coinName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(Int(holding.amount))")
                                    .frame(width: 80, alignment: .trailing)
                            }
                            Divider()
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Trades")
                        .font(.headline)

                    if viewModel.tradeHistory.isEmpty {
                        Text("No trade history yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.tradeHistory.prefix(5), id: \.id) { trade in
                            HStack {
                                Text(trade.type == .buy ? "Buy" : "Sell")
                                    .bold()
                                    .foregroundColor(trade.type == .buy ? .green : .red)

                                Text(trade.coinSymbol)
                                    .frame(width: 60, alignment: .leading)

                                Text("\(trade.amount, specifier: "%.4f")")
                                    .frame(width: 80, alignment: .trailing)

                                Text(trade.date.formatted(.dateTime.month().day().hour().minute()))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            Divider()
                        }
                    }
                }

                Button("Recharge via Bank") {
                    showRecharge = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showRecharge) {
            RechargeView()
                .environmentObject(viewModel)
        }
        .onAppear {
            print("✅ JimmyPortfolioView ")
        }
    }
}

#Preview {
    JimmyPortfolioView()
        .environmentObject(PortfolioViewModel())
}
