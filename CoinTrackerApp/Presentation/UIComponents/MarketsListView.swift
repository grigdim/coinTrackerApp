import SwiftUI

struct MarketsListView: View {
    let state: ViewState<[MarketRow]>

    let searchText: String
    let shouldPaginate: Bool?
    let thresholdIndex: Int?

    let onRetry: () -> Void
    let onRowAppear: (Int) -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            loadingRow

        case .failed(let error):
            LoadingErrorView(error: error, onRetry: onRetry)

        case .loaded(let coins):
            loadedRows(marketRows: coins)
        }
    }

    private var loadingRow: some View {
        HStack {
            Spacer()
            ProgressView("Loading…")
            Spacer()
        }
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private func loadedRows(marketRows: [MarketRow]) -> some View {
        let filtered = marketRows.filter {
            searchText.isEmpty
                || $0.name.localizedCaseInsensitiveContains(searchText)
        }

        ForEach(Array(filtered.enumerated()), id: \.element.id) { index, row in
            NavigationLink(
                value: CoinDetailsRoute(
                    id: row.id,
                    name: row.name,
                    iconURL: row.iconURL
                )
            ) {
                MarketRowItemView(
                    row: row
                ) {
                    onRowAppear(index)
                }
            }
        }
    }
}
