//
//  CoinDetailsMapper.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

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

        return CoinDetails(
            id: dto.id,
            name: dto.name,
            symbol: dto.symbol.uppercased(),
            iconURL: URL(string: dto.image.large ?? ""),
            price: formatCurrency(price),
            change24h: formatPercent(change24h),
            isUp: isUp,
            marketCap: formatCurrency(marketCap),
            volume: formatCurrency(volume),
            circulatingSupply: formatNumber(dto.marketData.circulatingSupply),
            ath: formatCurrency(ath),
            atl: formatCurrency(atl),
            sparkline: [], // comes from history endpoint later
            description: dto.description.en,
            websiteURL: firstValidURL(dto.links.homepage ?? []),
            explorerURL: firstValidURL(dto.links.blockchainSite ?? []),
            subredditURL: URL(string: dto.links.subredditUrl ?? "")
        )
    }

    // MARK: - Helpers

    private static func formatCurrency(_ value: Double?) -> String {
        guard let value else { return "—" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: value as NSNumber) ?? "—"
    }

    private static func formatPercent(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.2f%%", value)
    }

    private static func formatNumber(_ value: Double?) -> String {
        guard let value else { return "—" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "—"
    }

    private static func firstValidURL(_ strings: [String]) -> URL? {
        strings.compactMap { URL(string: $0) }.first
    }
}
