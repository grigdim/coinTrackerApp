import SwiftUI

struct MarketRowItemView: View {
    let row: MarketRow
    var index: Int = 0
    var thresholdIndex: Int = 0
    var shouldPaginate: Bool = false
    // Coordinate space name used to compute row offset for scroll tracking
    var coordinateSpaceName: String = "marketScrolled"
    // Whether to emit RowOffsetKey preference values
    var emitOffset: Bool = true

    var body: some View {
        CoinRowView(coin: row)
            .background(
                Group {
                    if emitOffset {
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: RowOffsetKey.self,
                                value: [
                                    row.id: geo.frame(in: .named(coordinateSpaceName)).minY
                                ]
                            )
                        }
                    } else {
                        Color.clear
                    }
                }
            )
            .id(row.id)
    }
}
#Preview {
    MarketRowItemView(row: MarketRow.sampleRows[0])
}
