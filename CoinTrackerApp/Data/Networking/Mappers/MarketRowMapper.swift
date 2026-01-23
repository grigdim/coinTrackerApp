import Foundation

struct MarketRowMapper {

    static func map(dto: MarketRowDTO) -> MarketRow {
        let change = dto.priceChangePercentage24h ?? 0

        return MarketRow(
            id: dto.id,
            name: dto.name,
            symbol: dto.symbol.uppercased(),
            iconURL: URL(string: dto.image ?? ""),

            price: CurrencyFormatter.usd(dto.currentPrice),
            marketCap: CurrencyFormatter.usdAbbreviated(dto.marketCap),
            volume: CurrencyFormatter.usdAbbreviated(dto.totalVolume),
            circulatingSupply: NumberFormatterUtil.abbreviated(
                dto.circulatingSupply
            ),

            ath: CurrencyFormatter.usd(dto.ath),
            atl: CurrencyFormatter.usd(dto.atl),

            change24h: PercentFormatter.twoDecimals(change),
            change24hRaw: change,
            isUp: change >= 0,

            sparkline: dto.sparklineIn7d?.price ?? []
        )
    }

    static func mapTrending(dto: TrendingCoinDTO) -> MarketRow {
        let usdKey = "usd"

        let priceValue = dto.data?.price
        let changeValue = dto.data?.priceChangePercentage24h?[usdKey]

        let marketCapText = MoneyStringFormatter.abbreviatedUSDString(
            dto.data?.marketCap
        )
        let volumeText = MoneyStringFormatter.abbreviatedUSDString(
            dto.data?.totalVolume
        )

        let changeRaw = changeValue ?? 0

        return MarketRow(
            id: dto.id,
            name: dto.name,
            symbol: dto.symbol.uppercased(),
            iconURL: URL(string: dto.large ?? ""),

            price: CurrencyFormatter.usd(priceValue),
            marketCap: marketCapText,
            volume: volumeText,

            // trending doesn’t provide these (keep placeholder)
            circulatingSupply: "—",
            ath: "—",
            atl: "—",

            change24h: PercentFormatter.twoDecimals(changeValue),
            change24hRaw: changeRaw,
            isUp: changeRaw >= 0,

            sparkline: []  // trending provides sparkline URL, not points
        )
    }
}
