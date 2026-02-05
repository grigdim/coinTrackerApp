import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: RootTab = .markets

    // Each tab gets its own navigation memory
    @State private var marketsPath = NavigationPath()
    @State private var searchPath = NavigationPath()
    @State private var watchlistsPath = NavigationPath()
    @State private var portfolioPath = NavigationPath()
    @State private var alertsPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationStack(path: $marketsPath) {
                MarketOverviewScreen()
            }
            .tabItem {
                Label(
                    RootTab.markets.title,
                    systemImage: RootTab.markets.systemImage
                )
            }
            .tag(RootTab.markets)

            NavigationStack(path: $searchPath) {
                SearchScreen()
            }
            .tabItem {
                Label(
                    RootTab.search.title,
                    systemImage: RootTab.search.systemImage
                )
            }
            .tag(RootTab.search)

            NavigationStack(path: $watchlistsPath) {
                WatchlistView()
            }
            .tabItem {
                Label(
                    RootTab.watchlists.title,
                    systemImage: RootTab.watchlists.systemImage
                )
            }
            .tag(RootTab.watchlists)

            NavigationStack(path: $portfolioPath) {
                PortfolioView()
            }
            .tabItem {
                Label(
                    RootTab.portfolio.title,
                    systemImage: RootTab.portfolio.systemImage
                )
            }
            .tag(RootTab.portfolio)

            NavigationStack(path: $alertsPath) {
                AlertsHomeView()
            }
            .tabItem {
                Label(
                    RootTab.alerts.title,
                    systemImage: RootTab.alerts.systemImage
                )
            }
            .tag(RootTab.alerts)
        }
        // Optional: set app accent color for the tab bar + nav buttons
//        .tint(.accentColor)
    }
}

#Preview {
    RootTabPreviewHost()
}

private struct RootTabPreviewHost: View {
    @StateObject private var stores = AppStores()
    @StateObject private var env = AppEnvironment(alertStore: AlertStore())

    var body: some View {
        RootTabView()
            .environmentObject(stores)
            .environmentObject(env)
            .task {
                await stores.categories.loadIfNeeded()
            }
    }
}
