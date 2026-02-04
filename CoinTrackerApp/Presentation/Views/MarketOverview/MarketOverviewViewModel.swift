import Combine
import Foundation

@MainActor
final class MarketOverviewViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[MarketRow]> = .idle
    @Published private(set) var isLoadingNextPage: Bool = false

    private let store: MarketsStore

    private var activeCategory: MarketCategory = .top100

    private(set) var scrollAnchorByCategory: [MarketCategory: String] = [:]

    private let perPage: Int = 10
    private let cacheTTL: TimeInterval = 60

    init(store: MarketsStore) {
        self.store = store
    }

    func loadMarketRows(for category: MarketCategory) async {
        activeCategory = category

        let cached = store.cachedRows(for: categoryResolver(category))
        if !cached.isEmpty {
            state = .loaded(cached)

            if let fetchedAtByCategory = store.fetchedAt(
                for: categoryResolver(category)
            ),
                !isStale(fetchedAtByCategory, cacheTTL: cacheTTL)
            {
                state = .loaded(present(cached, for: category))
                return
            }
        }

        await refreshMarketRows(for: category)
    }

    private func present(_ rows: [MarketRow], for category: MarketCategory)
        -> [MarketRow]
    {
        switch category {
        case .gainers:
            return Array(
                rows.sorted { $0.change24hRaw > $1.change24hRaw }.prefix(10)
            )
        case .losers:
            return Array(
                rows.sorted { $0.change24hRaw < $1.change24hRaw }.prefix(10)
            )
        default:
            return rows
        }
    }

    func refreshMarketRows(for category: MarketCategory) async {
        activeCategory = category
        state = .loading

        do {
            let effectivePerPage =
                (category == .gainers || category == .losers) ? 250 : perPage

            let marketRows = try await store.refresh(
                category: categoryResolver(category),
                perPage: effectivePerPage
            )

            guard activeCategory == category else { return }

            state = .loaded(present(marketRows, for: category))

        } catch {
            let cached = store.cachedRows(for: categoryResolver(category))
            if !cached.isEmpty {
                state = .loaded(present(cached, for: category))
            } else {
                state = .failed(error)
            }
        }
    }

    func loadNextPage(for category: MarketCategory) async {
        guard category == .top100 else { return }
        guard activeCategory == category else { return }
        guard case .loaded(let currentRows) = state else { return }
        guard !isLoadingNextPage else { return }

        isLoadingNextPage = true
        defer {
            isLoadingNextPage = false
        }

        do {
            let newRows = try await store.loadNextPage(
                category: categoryResolver(category),
                perPage: perPage
            )
            guard activeCategory == category else { return }
            state = .loaded(newRows)

        } catch {
            guard activeCategory == category else { return }
            state = .loaded(currentRows)
        }
    }

    func categoryResolver(_ category: MarketCategory) -> String {
        switch category {
        case .top100, .gainers, .losers:
            return "layer-1"
        case .trending:
            return "Trending"
        }
    }

    func saveScrolledAnchor(for category: MarketCategory, id: String) {
        scrollAnchorByCategory[category] = id
    }

    func scrollToAnchor(for category: MarketCategory) -> String? {
        scrollAnchorByCategory[category]
    }
}
