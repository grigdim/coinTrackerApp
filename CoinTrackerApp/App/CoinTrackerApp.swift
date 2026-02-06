import SwiftUI

@main
struct CoinTrackerApp: App {
    @StateObject private var stores = AppStores()
    @StateObject private var env = AppEnvironment(alertStore: AlertStore())
    @StateObject private var portfolioViewModel: PortfolioViewModel
        
        init() {
            let apiClient = APIClient()
            let repo = MarketRowRepositoryImpl(apiClient: apiClient)
            _portfolioViewModel = StateObject(wrappedValue: PortfolioViewModel(repository: repo))
        }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(stores)
                .task {
                    await stores.categories.loadIfNeeded()
                }
                .environmentObject(env)
                .environmentObject(portfolioViewModel)
                .task {
                    // Share the AlertStore with NotificationManager
                    NotificationManager.shared.alertStore = env.alertStore

                    // Ask for notification permission on first launch
                    await NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
