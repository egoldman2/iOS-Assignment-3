import SwiftUI

struct RechargeView: View {
    @EnvironmentObject var portfolioVM: PortfolioViewModel


    @State private var number = ""
    @State private var expiry = ""
    @State private var cvv = ""
    @State private var password = ""
    @State private var amount = ""

    @State private var showError = false
    @State private var goToPortfolio = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Credit Card Recharge")
                .font(.title2)
                .bold()

            TextField("Card Number", text: $number)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Expiry (MM/YY)", text: $expiry)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("CVV", text: $cvv)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Amount (AUD)", text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Pay") {
                if isCardInfoCorrect(), let value = Double(amount), value > 0 {
                    portfolioVM.charge(amount: value)
                    goToPortfolio = true
                } else {
                    showError = true
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isInputValid)

            Spacer()
        }
        .padding()
        .navigationTitle("Recharge")
        .alert("Card Info Incorrect", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please check your card number, expiry, CVV, or password.")
        }
        .navigationDestination(isPresented: $goToPortfolio) {
            JimmyPortfolioView()
                .environmentObject(portfolioVM)
        }
    }

    private func isCardInfoCorrect() -> Bool {
        let card = CreditCardData.card
        return number == card.cardNumber &&
               expiry == card.expiryDate &&
               cvv == card.cvv &&
               password == card.password
    }

    private var isInputValid: Bool {
        number.count == 16 &&
        cvv.count == 3 &&
        !expiry.isEmpty &&
        !password.isEmpty &&
        Double(amount) != nil
    }
}

