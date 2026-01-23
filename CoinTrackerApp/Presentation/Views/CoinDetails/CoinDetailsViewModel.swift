import Combine
import Foundation

@MainActor
final class CoinDetailsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<CoinDetails> = .idle
    @Published private(set) var isRefreshing: Bool = false

    private let getCoinDetails: GetCoinDetailsUseCase

    private var cachedCoinDetailsById: [String: Cached<CoinDetails>] = [:]

    // Prevent stale async results from overwriting UI
    private var activeCoinId: String?

    // Prevent duplicate refreshes
    private var refreshTask: Task<Void, Never>?

    private let cacheTTL: TimeInterval = 30

    init(getCoinDetails: GetCoinDetailsUseCase) {
        self.getCoinDetails = getCoinDetails
    }

    func loadCoinDetails(for id: String) async {
        activeCoinId = id

        // Serve cache immediately (if exists)
        if let cached = cachedCoinDetailsById[id] {
            state = .loaded(cached.value)

            // If still fresh -> return
            if !isStale(cached.fetchedAt, cacheTTL: cacheTTL) {
                return
            }

            // If stale -> refresh in background (keep UI)
            await refreshCoinDetails(for: id, showFullScreenLoading: false)
            return
        }

        // Refresh if no cache available -> full-screen loading
        await refreshCoinDetails(for: id, showFullScreenLoading: true)
    }

    func refreshCoinDetails(for id: String) async {
        await refreshCoinDetails(for: id, showFullScreenLoading: true)
    }

    private func refreshCoinDetails(for id: String, showFullScreenLoading: Bool)
        async
    {
        activeCoinId = id

        // cancel any in-flight refresh so only the latest wins
        refreshTask?.cancel()

        refreshTask = Task { [weak self] in
            guard let self else { return }

            if showFullScreenLoading {
                self.state = .loading
            } else {
                self.isRefreshing = true
            }

            defer { self.isRefreshing = false }

            do {
                let coinDetails = try await self.getCoinDetails.execute(for: id)

                guard !Task.isCancelled else { return }
                guard self.activeCoinId == id else { return }

                self.cachedCoinDetailsById[id] = Cached(
                    value: coinDetails,
                    fetchedAt: Date()
                )
                self.state = .loaded(coinDetails)

            } catch {
                guard !Task.isCancelled else { return }
                guard self.activeCoinId == id else { return }

                // If we have cached data, keep showing it (don’t blow up the UI)
                if let cached = self.cachedCoinDetailsById[id] {
                    self.state = .loaded(cached.value)
                } else {
                    self.state = .failed(error)
                }
            }
        }

        // Wait for the latest refresh task to finish (so callers can await)
        await refreshTask?.value
    }
}
