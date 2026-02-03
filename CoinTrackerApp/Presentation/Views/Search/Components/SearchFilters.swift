import Foundation

struct SearchFilters: Equatable {
    var price: ClosedRange<Double> = 0.0...200_000.0
    var marketCap: ClosedRange<Double> = 0.0...2_000_000_000_000.0
    var volume: ClosedRange<Double> = 0.0...2_000_000_000_000.0

    func matches(_ row: MarketRow) -> Bool {
        price.contains(row.priceRaw)
            && marketCap.contains(row.marketCapRaw)
            && volume.contains(row.volumeRaw)
    }

    static let `default` = SearchFilters()
}
