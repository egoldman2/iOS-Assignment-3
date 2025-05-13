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

struct SavedCardRow: View {
    let card: CreditCard
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("•••• •••• •••• " + card.cardNumber.suffix(4))
                        .font(.headline)
                    Text(card.holderName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RechargeView: View {
    // RechargeView allows users to top up their account using a credit card.
    // Supports both saved cards and adding new cards with expiry, CVV, and save options.
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var profileManager = ProfileManager.shared
    
    @State private var selectedCard: CreditCard?
    @State private var useNewCard = false
    
    // New card fields
    @State private var number = ""
    @State private var name = ""
    @State private var expiryMonth = "01"
    @State private var expiryYear = "25"
    @State private var cvv = ""
    @State private var amount = ""
    @State private var saveCard = false
    
    // UI states
    @State private var showError = false
    @State private var showSuccessAlert = false
    @State private var showMonthPicker = false
    @State private var showYearPicker = false
    
    let months = (1...12).map { String(format: "%02d", $0) }
    let years = (25...35).map { String(format: "%02d", $0) }
    
    private var savedCards: [CreditCard] {
        profileManager.activeProfile?.storedCards ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Page header with title and disclaimer text
                // Header
                VStack(spacing: 8) {
                    Text("💳 Credit Card Recharge")
                        .font(.title2)
                        .bold()
                    
                    Text("This is a demo application and does not actually perform any transactions.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Input for recharge amount using a numeric-only text field
                // Amount field (always visible)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount to Recharge")
                        .font(.headline)
                    
                    NumberOnlyTextField(text: $amount, maxLength: 10, placeholder: "Amount (AUD)")
                }
                .padding(.horizontal)
                
                // Display user's saved credit cards with option to select or add a new one
                // Saved Cards Section
                if !savedCards.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Saved Cards")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(savedCards, id: \.cardNumber) { card in
                            SavedCardRow(
                                card: card,
                                isSelected: selectedCard?.cardNumber == card.cardNumber && !useNewCard,
                                action: {
                                    selectedCard = card
                                    useNewCard = false
                                    // Clear new card fields when selecting saved card
                                    clearNewCardFields()
                                }
                            )
                            .padding(.horizontal)
                        }
                        
                        Button(action: {
                            useNewCard = true
                            selectedCard = nil
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add New Card")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                
                // Display new card input fields when no saved cards or user chooses to add a new one
                // New Card Section
                if savedCards.isEmpty || useNewCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(savedCards.isEmpty ? "Add a Credit Card" : "New Card Details")
                            .font(.headline)
                        
                        NumberOnlyTextField(text: $number, maxLength: 16, placeholder: "Card Number (16 digits)")
                        
                        TextField("Name on Card", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack(spacing: 10) {
                            Text("Expiry")
                                .frame(width: 70)
                            
                            Button(action: {
                                showMonthPicker.toggle()
                            }) {
                                Text(expiryMonth)
                                    .frame(width: 50, height: 35)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(5)
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
                            
                            Spacer()
                            
                            NumberOnlyTextField(text: $cvv, maxLength: 3, placeholder: "CVV")
                                .frame(width: 100)
                        }
                        
                        // Only show save option when adding new card
                        Toggle(isOn: $saveCard) {
                            Text("Save this card for future use")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Pay button to submit recharge request using selected or entered card info
                // Pay Button
                Button(action: handlePayment) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("Pay AUD $\(amount.isEmpty ? "0" : amount)")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceedWithPayment ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!canProceedWithPayment)
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Recharge")
        // Show month picker sheet for expiry selection
        .sheet(isPresented: $showMonthPicker) {
            monthPickerView
        }
        // Show year picker sheet for expiry selection
        .sheet(isPresented: $showYearPicker) {
            yearPickerView
        }
        // Show error alert if card information is invalid
        .alert("Card Info Incorrect", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please check your card number, expiry, CVV, or password.")
        }
        // Show success alert after recharge is processed
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("$\(amount) has been added to your account.")
        }
    }
    
    private var monthPickerView: some View {
        VStack {
            Text("Select Month")
                .font(.headline)
                .padding()
            
            Picker("Select Month", selection: $expiryMonth) {
                ForEach(months, id: \.self) { month in
                    Text(month).tag(month)
                }
            }
            .pickerStyle(.wheel)
            
            Button("Done") {
                showMonthPicker = false
            }
            .padding()
        }
        .presentationDetents([.fraction(0.3)])
    }
    
    private var yearPickerView: some View {
        VStack {
            Text("Select Year")
                .font(.headline)
                .padding()
            
            Picker("Select Year", selection: $expiryYear) {
                ForEach(years, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            .pickerStyle(.wheel)
            
            Button("Done") {
                showYearPicker = false
            }
            .padding()
        }
        .presentationDetents([.fraction(0.3)])
    }
    
    private var canProceedWithPayment: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        
        if let _ = selectedCard, !useNewCard {
            // Using saved card
            return true
        } else {
            // Using new card
            return number.count == 16 && cvv.count == 3 && !name.isEmpty
        }
    }
    
    // Process payment with either selected saved card or newly entered card info
    // Validates input, saves new card if chosen, and updates balance
    private func handlePayment() {
        guard let value = Double(amount), value > 0 else {
            showError = true
            return
        }
        
        if useNewCard || savedCards.isEmpty {
            // Validate new card info
            guard isCardInfoCorrect() else {
                showError = true
                return
            }
            
            // Save card if requested
            if saveCard {
                let newCard = CreditCard(
                    cardNumber: number,
                    expiryMonth: expiryMonth,
                    expiryYear: expiryYear,
                    cvv: cvv,
                    holderName: name
                )
                
                if profileManager.activeProfile?.storedCards == nil {
                    profileManager.activeProfile?.storedCards = []
                }
                profileManager.activeProfile?.storedCards.append(newCard)
                profileManager.saveProfiles()
            }
        }
        
        portfolioVM.charge(amount: value)
        showSuccessAlert = true
    }
    
    private func isCardInfoCorrect() -> Bool {
        return number.count == 16 && cvv.count == 3 && !name.isEmpty
    }
    
    private func clearNewCardFields() {
        number = ""
        name = ""
        cvv = ""
        expiryMonth = "01"
        expiryYear = "25"
        saveCard = false
    }
}

#Preview {
    NavigationStack {
        RechargeView()
            .environmentObject(PortfolioViewModel())
    }
}
