import Foundation

struct SearchFilters: Equatable {
    var price: ClosedRange<Double> = 0.0...200_000.0
    var marketCap: ClosedRange<Double> = 0.0...2_000_000_000_000.0
    var volume: ClosedRange<Double> = 0.0...2_000_000_000_000.0

    //    var category: String? = nil

    func matches(_ row: MarketRow) -> Bool {
        price.contains(row.priceRaw)
            && marketCap.contains(row.marketCapRaw)
            && volume.contains(row.volumeRaw)
        //            && matchesCategory(row)
    }

    //    private func matchesCategory(_ row: MarketRow) -> Bool {
    //        guard let category else { return true }
    //        return row.category == category
    //    }

    static let `default` = SearchFilters()
}
