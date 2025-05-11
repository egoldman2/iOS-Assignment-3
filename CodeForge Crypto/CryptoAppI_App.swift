import SwiftUI

@main
struct CryptoAppI_App: App {
    @StateObject private var marketVM = MarketViewModel()
    @StateObject private var portfolioVM = PortfolioViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {       
                WelcomeView()
                    .environmentObject(marketVM)
                    .environmentObject(portfolioVM)
            }
        }
    }
}

