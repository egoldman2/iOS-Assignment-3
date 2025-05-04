import SwiftUI
struct UserAccount: Identifiable {
    let id: UUID = UUID()
    var email: String
    var name: String
    var password: String
    var balance: Double = 10000.0
}

