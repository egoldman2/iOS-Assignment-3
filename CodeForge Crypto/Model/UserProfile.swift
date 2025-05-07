import SwiftUI
struct UserAccount: Codable {
    var email: String
    var name: String
    var pin: String
    var holdings: [Holding]
    var accountBalance: Int
}

