import SwiftUI

struct UserAccount: Codable {
    var email: String
    var name: String
    var pin: String
    var holdings: [Holding]
    var storedCards: [CreditCard]
    var accountBalance: Int
}

