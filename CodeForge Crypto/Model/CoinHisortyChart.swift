import SwiftUI
import Foundation

struct CoinHistoryChart : Identifiable {
    let id: UUID = UUID()
    let time : Date
    let price : Double
}

enum ChartRange: Int, CaseIterable {
    case week = 7
    case month = 30
    case year = 365

    var label: String {
        switch self {
        case .week: return "7D"
        case .month: return "30D"
        case .year: return "365D"
        }
    }

    var fromTimestamp: Int {
        let now = Date()
        let from = now.addingTimeInterval(Double(-self.rawValue * 86400))
        return Int(from.timeIntervalSince1970)
    }

    var toTimestamp: Int {
        return Int(Date().timeIntervalSince1970)
    }
}
