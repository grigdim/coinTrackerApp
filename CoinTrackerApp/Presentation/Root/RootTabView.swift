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

            // MARK markets path
            NavigationStack(path: $marketsPath) {
                MarketOverviewView()
                    .navigationTitle("Markets")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label(RootTab.markets.title, systemImage: RootTab.markets.systemImage)
            }
            .tag(RootTab.markets)

            // MARK search path
            NavigationStack(path: $searchPath) {
                SearchView()
                    .navigationTitle("Search")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label(RootTab.search.title, systemImage: RootTab.search.systemImage)
            }
            .tag(RootTab.search)

            // MARK watchlists path
//            NavigationStack(path: $watchlistsPath) {
//                WatchlistView()
//                    .navigationTitle("Watchlists")
//                    .navigationBarTitleDisplayMode(.large)
//            }
            .tabItem {
                Label(RootTab.watchlists.title, systemImage: RootTab.watchlists.systemImage)
            }
            .tag(RootTab.watchlists)
            
            // MARK portfolio path
            NavigationStack(path: $portfolioPath) {
                PortfolioView()
                    .navigationTitle("Portfolio")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label(RootTab.portfolio.title, systemImage: RootTab.portfolio.systemImage)
            }
            .tag(RootTab.portfolio)

            // MARK alerts path
            NavigationStack(path: $alertsPath) {
                AlertsView()
                    .navigationTitle("Alerts")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label(RootTab.alerts.title, systemImage: RootTab.alerts.systemImage)
            }
            .tag(RootTab.alerts)
        }
    }
}

#Preview {
    RootTabView()
}
