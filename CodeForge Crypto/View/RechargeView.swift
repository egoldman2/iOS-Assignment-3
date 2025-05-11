import SwiftUI

struct NumberOnlyTextField: View {
    @Binding var text: String
    var maxLength: Int
    var placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(.numberPad)
            .onChange(of: text) { newValue, _ in
                // Only allow numbers
                let filtered = newValue.filter { "0123456789".contains($0) }
                
                // Enforce max length
                if filtered.count > maxLength {
                    text = String(filtered.prefix(maxLength))
                } else {
                    text = filtered
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct RechargeView: View {
    @EnvironmentObject var portfolioVM: PortfolioViewModel

    @State private var number = ""
    @State private var name = ""
    @State private var expiryMonth = "01"
    @State private var expiryYear = "25"
    let months = (1...12).map { String(format: "%02d", $0) }
    let years = (25...35).map { String(format: "%02d", $0) }
    @State private var cvv = ""
    @State private var amount = ""

    @State private var showError = false
    @State private var goToPortfolio = false

    // States for bottom sheet presentation
    @State private var showMonthPicker = false
    @State private var showYearPicker = false
    
    @State private var saveCard = false

    var body: some View {
        VStack(spacing: 20) {
            Text("💳 Credit Card Recharge")
                .font(.title2)
                .bold()
            
            Text("This is a demo application and does not actually perform any transactions.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            if let storedCards = ProfileManager.shared.activeProfile?.storedCards{
                Text("Saved Cards")
                
                List(storedCards, id: \.cardNumber) { card in
                    Text(card.cardNumber.suffix(4))
                }
                
            }


            Group {
                Text("Add a New Card")
                
                NumberOnlyTextField(text: $number, maxLength: 16, placeholder: "Card Number (16 digits)")

                TextField("Name on Card", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack(spacing: 5) {
                    Text("Expiry:")
                    
                    Button(action: {
                        showMonthPicker.toggle()
                    }) {
                        Text(expiryMonth)
                            .frame(width: 50, height: 35)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .sheet(isPresented: $showMonthPicker) {
                        Picker("Select Month", selection: $expiryMonth) {
                            ForEach(months, id: \.self) { month in
                                Text(month).tag(month)
                            }
                        }
                        .pickerStyle(.wheel)
                        .presentationDetents([.fraction(0.2)])
                    }
                    
                    Text("/")
                    
                    Button(action: {
                        showYearPicker.toggle()
                    }) {
                        Text(expiryYear)
                            .frame(width: 50, height: 35)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .sheet(isPresented: $showYearPicker) {
                        Picker("Select Year", selection: $expiryYear) {
                            ForEach(years, id: \.self) { year in
                                Text(year).tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                        .presentationDetents([.fraction(0.2)])
                    }
                    
                    Spacer()
                    
                    NumberOnlyTextField(text: $cvv, maxLength: 3, placeholder: "CVV (3 digits)")
                        .frame(width: .infinity)
                }
            }

            NumberOnlyTextField(text: $amount, maxLength: 10, placeholder: "Amount (AUD)")
            
            Toggle(isOn: $saveCard) {
                Text("Save Card")
            }

            Button("Pay") {
                if isCardInfoCorrect(), let value = Double(amount), value > 0 {
                    ProfileManager.shared.activeProfile?.storedCards.append(CreditCard(cardNumber: number, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv, holderName: name))
                    portfolioVM.charge(amount: value)
                    goToPortfolio = true
                } else {
                    showError = true
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isInputValid)
            .padding(.top, 10)

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
        return number.count == 16 && cvv.count == 3
    }

    private var isInputValid: Bool {
        number.count == 16 &&
        cvv.count == 3 &&
        Double(amount) != nil
    }
}

#Preview {
    RechargeView()
        .environmentObject(PortfolioViewModel())
}
