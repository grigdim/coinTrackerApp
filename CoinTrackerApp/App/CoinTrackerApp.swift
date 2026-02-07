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
                .environmentObject(env.alertStore)
                .environmentObject(portfolioViewModel)
                .task {
                    await stores.categories.loadIfNeeded()
                }
                .task {
                    NotificationManager.shared.alertStore = env.alertStore
                    await NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
