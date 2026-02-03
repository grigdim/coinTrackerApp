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

    private static func firstValidURL(_ strings: [String]) -> URL? {
        strings
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first(where: { !$0.isEmpty })
            .flatMap(URL.init(string:))
    }
}
