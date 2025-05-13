import Foundation

class CreditCard : Codable {
    let cardNumber: String
    var expiryDate: Date
    let cvv: String
    let holderName: String

    // Initializer with property assignment
    init(cardNumber: String, expiryDate: Date, cvv: String, holderName: String) {
        self.cardNumber = cardNumber
        self.expiryDate = expiryDate
        self.cvv = cvv
        self.holderName = holderName
    }
    
    init(cardNumber: String, expiryMonth: String, expiryYear: String, cvv: String, holderName: String) {
        self.cardNumber = cardNumber
        self.expiryDate = Date(timeIntervalSince1970: 0)
        self.cvv = cvv
        self.holderName = holderName
        self.expiryDate = convertToDate(month: expiryMonth, year: expiryYear)
    }

    func convertToDate(month: String, year: String) -> Date {
        // Validate inputs
        guard let monthInt = Int(month), (1...12).contains(monthInt),
              let _ = Int(year), year.count == 2 else {
            return Date(timeIntervalSince1970: 0)
        }

        // Construct the date string in "MM/YY" format
        let dateString = "\(month)/\(year)"
        
        // Date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Convert to Date
        return dateFormatter.date(from: dateString) ?? Date(timeIntervalSince1970: 0)
    }
    
}
