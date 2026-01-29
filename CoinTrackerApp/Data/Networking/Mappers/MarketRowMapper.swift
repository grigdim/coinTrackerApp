import Foundation

struct MarketRowMapper {

    private static func url(_ string: String?) -> URL? {
        URL(string: string ?? "")
    }
    private static func nonNil(_ value: Double?) -> Double { value ?? 0.0 }

    static func map(dto: MarketRowDTO) -> MarketRow {
        let change = dto.priceChangePercentage24h ?? 0
        let price = nonNil(dto.currentPrice)
        let marketCap = nonNil(dto.marketCap)
        let volume = nonNil(dto.totalVolume)

        return MarketRow(
            id: dto.id,
            name: dto.name,
            symbol: dto.symbol.uppercased(),
            iconURL: Self.url(dto.image),

            price: CurrencyFormatter.usd(price),
            priceRaw: price,
            marketCap: CurrencyFormatter.usdAbbreviated(marketCap),
            marketCapRaw: marketCap,
            volume: CurrencyFormatter.usdAbbreviated(volume),
            volumeRaw: volume,
            circulatingSupply: NumberFormatterUtil.abbreviated(
                nonNil(dto.circulatingSupply)
            ),

            ath: CurrencyFormatter.usd(nonNil(dto.ath)),
            atl: CurrencyFormatter.usd(nonNil(dto.atl)),

            change24h: PercentFormatter.twoDecimals(change),
            change24hRaw: change,
            isUp: change >= 0,

            sparkline: dto.sparklineIn7d?.price ?? []
        )
    }

    static func mapTrending(dto: TrendingCoinDTO) -> MarketRow {
        let price = nonNil(dto.data?.price)
        let change = nonNil(dto.data?.priceChangePercentage24h?["usd"])

        let marketCapText = MoneyStringFormatter.abbreviatedUSDString(
            dto.data?.marketCap
        )
        let volumeText = MoneyStringFormatter.abbreviatedUSDString(
            dto.data?.totalVolume
        )

        let changeRaw = change

        return MarketRow(
            id: dto.id,
            name: dto.name,
            symbol: dto.symbol.uppercased(),
            iconURL: Self.url(dto.large),

            price: CurrencyFormatter.usd(price),
            priceRaw: price,
            marketCap: marketCapText,
            marketCapRaw: nonNil(
                MoneyStringFormatter.parseMoneyToDouble(
                    dto.data?.marketCap ?? "-"
                )
            ),
            volume: volumeText,
            volumeRaw: nonNil(
                MoneyStringFormatter.parseMoneyToDouble(
                    dto.data?.totalVolume ?? "-"
                )
            ),

            // trending doesn’t provide these (keep placeholder)
            circulatingSupply: "—",
            ath: "—",
            atl: "—",

            change24h: PercentFormatter.twoDecimals(change),
            change24hRaw: changeRaw,
            isUp: changeRaw >= 0,

            sparkline: []
        )
    }
}
