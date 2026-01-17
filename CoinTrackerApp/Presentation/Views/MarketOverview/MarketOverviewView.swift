import SwiftUI

private struct CoinDetailsRoute: Hashable {
    let id: String
    let name: String
}

private struct MarketOverviewNoSearchResultsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("No results")
                .font(.headline)

            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct MarketOverviewView: View {
    @StateObject private var viewModel = MarketOverviewViewModel()
    @State private var selectedCategory: MarketCategory = .top100
    @State private var searchText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Picker("Category", selection: $selectedCategory) {
                ForEach(MarketCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // We keep the search host (List) present and change content within it.
            // This reduces search bar jumping/disappearing.
            contentList
        }
        .task { await viewModel.load(for: selectedCategory) }
        .navigationDestination(for: CoinDetailsRoute.self) { route in
            CoinDetailsView()
                .navigationTitle(route.name)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var contentList: some View {
        // Resolve coins for the list without removing the list from the hierarchy.
        let coins: [CoinRowView.CoinModel] = {
            if case .loaded(let c) = viewModel.state { return c }
            return []
        }()

        let filtered = coins.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }

        let shouldPaginate = selectedCategory == .top100 && searchText.isEmpty
        let thresholdIndex = max(0, filtered.count - 5)

        return ScrollViewReader { proxy in
            List {
                // Loading / error as list rows (simple approach).
                // If you prefer overlays, you can do that too.
                switch viewModel.state {
                case .idle, .loading:
                    HStack {
                        Spacer()
                        ProgressView("Loading…")
                        Spacer()
                    }
                    .listRowSeparator(.hidden)

                case .failed(let error):
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)

                        Text("Couldn’t load markets").font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task { await viewModel.refresh(for: selectedCategory) }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowSeparator(.hidden)

                case .loaded:
                    // Main rows
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, coin in
                        NavigationLink(value: CoinDetailsRoute(id: coin.id, name: coin.name)) {
                            CoinRowView(coin: coin)
                                .onAppear {
                                    guard shouldPaginate else { return }
                                    if index >= thresholdIndex {
                                        guard selectedCategory == .top100 else { return }
                                        Task { await viewModel.loadNextPage(for: selectedCategory) }
                                    }
                                }
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: RowOffsetKey.self,
                                            value: [coin.id: geo.frame(in: .named("marketScrolled")).minY]
                                        )
                                    }
                                )
                        }
                        // Important for scrollTo:
                        .id(coin.id)
                    }

                    // Footer loading indicator
                    if shouldPaginate && viewModel.isLoadingNextPage {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .coordinateSpace(name: "marketScrolled")
            .searchable(text: $searchText, prompt: "Search coins")
            .refreshable { await viewModel.refresh(for: selectedCategory) }
            .overlay {
                if case .loaded = viewModel.state, filtered.isEmpty {
                    MarketOverviewNoSearchResultsView()
                }
            }
            .onPreferenceChange(RowOffsetKey.self) { offsets in
                let visible = offsets.filter { $0.value >= 0 }
                if let topMost = visible.min(by: { $0.value < $1.value })?.key {
                    viewModel.saveScrolledAnchor(for: selectedCategory, id: topMost)
                }
            }
            .onChange(of: selectedCategory) { newValue in
                Task {
                    await viewModel.load(for: newValue)
                    guard selectedCategory == newValue else { return }
                    if let anchor = viewModel.scrollToAnchor(for: newValue) {
                        // yield so the list has time to lay out
                        try? await Task.sleep(nanoseconds: 50_000_000)
                        proxy.scrollTo(anchor, anchor: .top)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MarketOverviewView()
            .navigationTitle("Markets")
            .navigationBarTitleDisplayMode(.inline)
    }
}
