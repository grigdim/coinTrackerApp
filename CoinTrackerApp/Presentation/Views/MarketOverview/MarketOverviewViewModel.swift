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

        let cached = store.cachedRows(for: category)
        if !cached.isEmpty {
            state = .loaded(cached)

            if let fetchedAtByCategory = store.fetchedAt(for: category),
                !isStale(fetchedAtByCategory, cacheTTL: cacheTTL)
            {
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
            return rows.sorted {
                $0.change24hRaw > $1.change24hRaw
            }
        case .losers:
            return rows.sorted {
                $0.change24hRaw < $1.change24hRaw
            }
        default:
            return rows
        }
    }

    func refreshMarketRows(for category: MarketCategory) async {
        activeCategory = category
        state = .loading

        do {
            let marketRows = try await store.refresh(
                category: category,
                perPage: perPage
            )
            guard activeCategory == category else { return }

            state = .loaded(present(marketRows, for: category))

        } catch {
            let cached = store.cachedRows(for: category)
            if !cached.isEmpty {
                state = .loaded(cached)
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
                category: category,
                perPage: perPage
            )

            state = .loaded(newRows)

        } catch {
            state = .loaded(currentRows)
        }
    }

    func saveScrolledAnchor(for category: MarketCategory, id: String) {
        scrollAnchorByCategory[category] = id
    }

    func scrollToAnchor(for category: MarketCategory) -> String? {
        scrollAnchorByCategory[category]
    }
}
