struct CreditCard {
    let cardNumber: String
        let expiryDate: String
        let cvv: String
        let password: String
        let holderName: String
}

struct CreditCardData {
    static let card = CreditCard(
        cardNumber: "4111111111111111",
        expiryDate: "12/25",
        cvv: "123",
        password: "1234",
        holderName: "Jimmy Smith"
    )
}
