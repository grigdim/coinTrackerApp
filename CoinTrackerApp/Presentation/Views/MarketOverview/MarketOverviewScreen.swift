import SwiftUI

struct MarketOverviewScreen: View {
    @EnvironmentObject private var stores: AppStores

    var body: some View {
        MarketOverviewView(
            viewModel: MarketOverviewViewModel(store: stores.markets)
        )
        .navigationTitle("Markets")
        .navigationBarTitleDisplayMode(.large)
    }
}
