import SwiftUI

@main
struct CryptoAppI_App: App {
    @StateObject private var marketVM = MarketViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {       
                HomeView()
                    .environmentObject(marketVM)
            }
        }
    }
}

