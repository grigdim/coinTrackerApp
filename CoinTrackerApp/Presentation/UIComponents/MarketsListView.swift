import SwiftUI

struct MarketsListView: View {
    let state: ViewState<[MarketRow]>
    let searchText: String

    let onRetry: () -> Void
    /// Called with the row index *in the filtered array* when that row appears.
    let onRowAppear: (Int) -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            loadingRow

        case .failed(let error):
            LoadingErrorView(error: error, onRetry: onRetry)
                .listRowSeparator(.hidden)

        case .loaded(let rows):
            loadedRows(rows)
        }
    }

    private var loadingRow: some View {
        HStack(spacing: 10) {
            ProgressView()
                .controlSize(.regular)

            Text("Loading…")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    @ViewBuilder
    private func loadedRows(_ rows: [MarketRow]) -> some View {
        let filtered = rows.filter {
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
                    row: row,
                    onAppear: { onRowAppear(index) }
                )
            }
            .listRowInsets(
                EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            )
            .contentShape(Rectangle())
        }
    }
}
