import Combine
import Foundation

@MainActor
final class MarketOverviewViewModel: ObservableObject {

    // Cache per category + when it was fetched (used for TTL)
    private var cacheByCategory: [MarketCategory: Cached<[MarketRow]>] = [:]

    // Only meaningful if you keep pagination for Top100
    private var loadedPageByCategory: [MarketCategory: Int] = [:]
    private var inFlightPageByCategory: [MarketCategory: Int] = [:]

    // Prevent stale async work from overwriting the UI after switching tabs
    private var activeCategory: MarketCategory = .top100

    private(set) var scrollAnchorByCategory: [MarketCategory: String] = [:]

    private let getMarketRows: GetMarketRowsUseCase

    private let perPage: Int = 100
    private let cacheTTL: TimeInterval = 60

    @Published private(set) var isLoadingNextPage: Bool = false
    @Published private(set) var state: ViewState<[MarketRow]> = .idle

    init(getMarketRows: GetMarketRowsUseCase) {
        self.getMarketRows = getMarketRows
    }

    // Show cache immediately (fast UI). If stale, refresh in the background.
    func loadMarketRows(for category: MarketCategory) async {
        activeCategory = category

        if let cached = cacheByCategory[category], !cached.value.isEmpty {
            state = .loaded(cached.value)

            loadedPageByCategory[category] = loadedPageByCategory[category] ?? 1

            if !isStale(cached.fetchedAt, cacheTTL: cacheTTL) {
                return
            }
        }

        await refreshMarketRows(for: category)
    }

    // Pull-to-refresh should always call this (forces network attempt).
    func refreshMarketRows(for category: MarketCategory) async {
        activeCategory = category
        state = .loading

        // If you drop pagination, you can delete these.
        loadedPageByCategory[category] = 1
        inFlightPageByCategory[category] = nil

        do {
            let marketRows = try await getMarketRows.execute(
                category: category,
                perPage: perPage,
                page: 1,
                ids: nil
            )

            let finalRows: [MarketRow]
            switch category {
            case .gainers:
                finalRows = marketRows.sorted {
                    $0.change24hRaw > $1.change24hRaw
                }
            case .losers:
                finalRows = marketRows.sorted {
                    $0.change24hRaw < $1.change24hRaw
                }
            default:
                finalRows = marketRows
            }

            cacheByCategory[category] = Cached(
                value: finalRows,
                fetchedAt: Date()
            )
            state = .loaded(finalRows)

        } catch {
            if let cached = cacheByCategory[category]?.value, !cached.isEmpty {
                // Keep showing cached data if refresh fails
                state = .loaded(cached)
            } else {
                state = .failed(error)
            }
        }
    }

    func loadNextPage(for category: MarketCategory) async {
        guard category == .top100 else { return }
        guard activeCategory == category else { return }
        guard case .loaded = state else { return }
        guard !isLoadingNextPage else { return }

        let currentLoadedPage = loadedPageByCategory[category] ?? 1
        let nextPage = currentLoadedPage + 1

        if inFlightPageByCategory[category] == nextPage { return }

        inFlightPageByCategory[category] = nextPage
        isLoadingNextPage = true
        defer {
            isLoadingNextPage = false
            if inFlightPageByCategory[category] == nextPage {
                inFlightPageByCategory[category] = nil
            }
        }

        // Important: re-check after any await in real code.
        guard activeCategory == category else { return }
        guard case .loaded(let currentNow) = state else { return }

        do {
            let newRows = try await getMarketRows.execute(
                category: category,
                perPage: perPage,
                page: nextPage,
                ids: nil
            )

            let merged = currentNow + newRows
            cacheByCategory[category] = Cached(value: merged, fetchedAt: Date())
            state = .loaded(merged)
            loadedPageByCategory[category] = nextPage

        } catch {
            // Keep current UI; don't turn the whole screen into an error
            state = .loaded(currentNow)
        }
    }

    func saveScrolledAnchor(for category: MarketCategory, id: String) {
        scrollAnchorByCategory[category] = id
    }

    func scrollToAnchor(for category: MarketCategory) -> String? {
        scrollAnchorByCategory[category]
    }
}
