import SwiftUI

struct SearchScreen: View {
    @EnvironmentObject private var stores: AppStores

    var body: some View {
        SearchView(
            viewModel: SearchViewModel(
                marketsStore: stores.markets,
                categoriesStore: stores.categories
            )
        )
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
    }
}
