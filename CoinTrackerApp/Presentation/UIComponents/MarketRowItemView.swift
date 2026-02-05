import SwiftUI

struct MarketRowItemView: View {
    let row: MarketRow
    var onAppear: () -> Void = {}

    // Coordinate space name used to compute row offset for scroll tracking
    var coordinateSpaceName: String = "marketScrolled"

    // Whether to emit RowOffsetKey preference values
    var emitOffset: Bool = true

    var body: some View {
        CoinRowView(coin: row)
            .background {
                if emitOffset {
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: RowOffsetKey.self,
                                value: [
                                    row.id: geo.frame(
                                        in: .named(coordinateSpaceName)
                                    ).minY
                                ]
                            )
                    }
                    .allowsHitTesting(false)
                }
            }
            .id(row.id)
            .onAppear(perform: onAppear)
    }
}

#Preview {
    MarketRowItemView(row: MarketRow.sampleRows[0])
}
