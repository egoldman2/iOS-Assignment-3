import Foundation
import SwiftUI
enum TradeType: String, Codable {
    case buy
    case sell
}

struct TradeRecord: Codable, Identifiable {
    var id = UUID()
    let coinID: String
    let coinSymbol: String
    let coinName: String
    let date: Date
    let type: TradeType
    let amount: Double
    let currentPrice: Double   
}

