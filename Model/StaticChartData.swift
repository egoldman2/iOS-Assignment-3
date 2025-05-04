// if fetch chart history data fail
//switch to this one

import Foundation

let StaticChartPoints: [CoinHistoryChart] = [
    CoinHistoryChart(time: Date().addingTimeInterval(-86400 * 6), price: 97000),
    CoinHistoryChart(time: Date().addingTimeInterval(-86400 * 5), price: 98000),
    CoinHistoryChart(time: Date().addingTimeInterval(-86400 * 4), price: 96000),
    CoinHistoryChart(time: Date().addingTimeInterval(-86400 * 3), price: 99000),
    CoinHistoryChart(time: Date().addingTimeInterval(-86400 * 2), price: 100000),
    CoinHistoryChart(time: Date().addingTimeInterval(-86400 * 1), price: 102000),
    CoinHistoryChart(time: Date(), price: 101500)
]

