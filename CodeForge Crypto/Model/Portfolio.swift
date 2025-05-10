import SwiftUI
struct Portfolio: Codable {
    var balance: Double
    var holdings: [StoredHolding]
    var tradeHistory: [TradeRecord]
}

