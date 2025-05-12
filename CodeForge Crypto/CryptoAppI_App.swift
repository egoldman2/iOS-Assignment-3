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
            .onAppear {
                // Load saved profiles on app launch
                ProfileManager.shared.loadProfiles()
            }
        }
    }
}

// Add this extension here
extension CryptoAppI_App {
    func rootView() -> some View {
        NavigationStack {
            WelcomeView()
                .environmentObject(MarketViewModel())
                .environmentObject(PortfolioViewModel())
        }
    }
}
