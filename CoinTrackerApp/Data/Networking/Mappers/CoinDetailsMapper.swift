import Foundation

struct CoinDetailsMapper {
    static func map(dto: CoinDetailDTO) -> CoinDetails {
        let usd = "usd"

        let price = dto.marketData.currentPrice?[usd]
        let marketCap = dto.marketData.marketCap?[usd]
        let volume = dto.marketData.totalVolume?[usd]
        let ath = dto.marketData.ath?[usd]
        let atl = dto.marketData.atl?[usd]

        let change24h = dto.marketData.priceChangePercentage24h
        let isUp = (change24h ?? 0) >= 0

        let iconURL = URL(string: dto.image.large ?? "")

        return CoinDetails(
            id: dto.id,
            name: dto.name,
            symbol: dto.symbol.uppercased(),
            iconURL: iconURL,

            price: CurrencyFormatter.usd(price),
            change24h: PercentFormatter.twoDecimals(change24h),
            isUp: isUp,

            marketCap: CurrencyFormatter.usdAbbreviated(marketCap),
            volume: CurrencyFormatter.usdAbbreviated(volume),

            circulatingSupply: NumberFormatterUtil.abbreviated(
                dto.marketData.circulatingSupply
            ),

            ath: CurrencyFormatter.usdAbbreviated(ath),
            atl: CurrencyFormatter.usdAbbreviated(atl),

            sparkline: [],
            description: dto.description.en,

            websiteURL: firstValidURL(dto.links.homepage ?? []),
            explorerURL: firstValidURL(dto.links.blockchainSite ?? []),
            subredditURL: URL(string: dto.links.subredditUrl ?? "")
        )
    }

    // MARK: - Helpers

    private static func firstValidURL(_ strings: [String]) -> URL? {
        strings
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first(where: { !$0.isEmpty })
            .flatMap(URL.init(string:))
    }
}

// MARK: - Formatting Helpers (keep these in the same file for now; later you can move to Utils)

enum CurrencyFormatter {
    static func usd(_ value: Double?) -> String {
        guard let value else { return "—" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0

        return formatter.string(from: NSNumber(value: value)) ?? "—"
    }

    static func usdAbbreviated(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "$" + AbbreviatedNumberFormatter.format(value)
    }
}

enum PercentFormatter {
    static func twoDecimals(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.2f%%", value)
    }
}

enum NumberFormatterUtil {
    static func abbreviated(_ value: Double?) -> String {
        guard let value else { return "—" }
        return AbbreviatedNumberFormatter.format(value)
    }
}

enum MoneyStringFormatter {
    /// Accepts strings like "$99,703,583" and returns "99.7M" (no $) or "—"
    static func abbreviatedUSDString(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "—" }
        let number = parseMoneyToDouble(value)
        guard let number else { return value } // fallback: show original string
        return "$" + AbbreviatedNumberFormatter.format(number)
    }

    /// Accepts strings like "$282,142" and returns "$282K" etc.
    private static func parseMoneyToDouble(_ s: String) -> Double? {
        // keep digits and dot only
        let cleaned = s
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Double(cleaned)
    }
}
