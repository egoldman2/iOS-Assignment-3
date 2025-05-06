import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    var body: some View {
        VStack {
            Text("Your Portfolio")
                .font(.largeTitle)
                .bold()
            List {
                ForEach(viewModel.holdings, id: \.id) { holding in
                    HStack {
                        Text(holding.coinName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: "%.4f", holding.amountHeld))
                            .frame(width: 80, alignment: .trailing)
                        Text(String(format: "$%.2f", holding.totalValueUSD))
                            .frame(width: 100, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView()
}
