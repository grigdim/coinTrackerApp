//
//  MarketCoin.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

struct MarketRow: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String

    let iconURL: URL?

    // UI-formatted values
    let price: String
    let priceRaw: Double
    let marketCap: String
    let marketCapRaw: Double
    let volume: String
    let volumeRaw: Double
    let circulatingSupply: String

    let ath: String
    let atl: String

    let change24h: String
    let change24hRaw: Double
    let isUp: Bool

    let sparkline: [Double]
    let currentPriceRaw: Double
}
extension MarketRow {
    static let sampleRows: [MarketRow] = [
        MarketRow(
            id: "bitcoin",
            name: "Bitcoin",
            symbol: "BTC",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
            price: "$43,210.12",
            priceRaw: 43210.12,
            marketCap: "$847.2B",
            marketCapRaw: 847200000000,
            volume: "$21.3B",
            volumeRaw: 21300000000,
            circulatingSupply: "19.4M BTC",
            ath: "$69,044",
            atl: "$67",
            change24h: "+2.45%",
            change24hRaw: 2.45,
            isUp: true,
            sparkline: [41200, 41800, 41550, 42010, 42500, 43000, 42800, 43300, 43200, 43550],
            currentPriceRaw: 0.0
        ),
        MarketRow(
            id: "ethereum",
            name: "Ethereum",
            symbol: "ETH",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
            price: "$2,310.85",
            priceRaw: 2310.85,
            marketCap: "$277.4B",
            marketCapRaw: 277400000000,
            volume: "$8.9B",
            volumeRaw: 8900000000,
            circulatingSupply: "120.2M ETH",
            ath: "$4,878",
            atl: "$0.43",
            change24h: "+1.12%",
            change24hRaw: 1.12,
            isUp: true,
            sparkline: [2240, 2265, 2250, 2288, 2300, 2315, 2298, 2325, 2310, 2332],
            currentPriceRaw: 0.0
        ),
        MarketRow(
            id: "tether",
            name: "Tether",
            symbol: "USDT",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/325/large/Tether-logo.png"),
            price: "$1.00",
            priceRaw: 1.0,
            marketCap: "$95.0B",
            marketCapRaw: 95000000000,
            volume: "$35.1B",
            volumeRaw: 35100000000,
            circulatingSupply: "95.0B USDT",
            ath: "$1.32",
            atl: "$0.57",
            change24h: "+0.01%",
            change24hRaw: 0.01,
            isUp: true,
            sparkline: [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
            currentPriceRaw: 0.0
        ),
        MarketRow(
            id: "binancecoin",
            name: "BNB",
            symbol: "BNB",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/825/large/binance-coin-logo.png"),
            price: "$312.40",
            priceRaw: 312.40,
            marketCap: "$48.2B",
            marketCapRaw: 48200000000,
            volume: "$1.2B",
            volumeRaw: 1200000000,
            circulatingSupply: "153.9M BNB",
            ath: "$690",
            atl: "$0.03",
            change24h: "-0.54%",
            change24hRaw: -0.54,
            isUp: false,
            sparkline: [305, 307, 306, 309, 311, 313, 312, 314, 313, 312],
            currentPriceRaw: 0.0
        ),
        MarketRow(
            id: "ripple",
            name: "XRP",
            symbol: "XRP",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/44/large/xrp.png"),
            price: "$0.57",
            priceRaw: 0.57,
            marketCap: "$30.8B",
            marketCapRaw: 30800000000,
            volume: "$1.1B",
            volumeRaw: 1100000000,
            circulatingSupply: "53.7B XRP",
            ath: "$3.40",
            atl: "$0.0028",
            change24h: "+0.83%",
            change24hRaw: 0.83,
            isUp: true,
            sparkline: [0.55, 0.552, 0.553, 0.558, 0.561, 0.565, 0.563, 0.569, 0.568, 0.57],
            currentPriceRaw: 0.0
        ),
        MarketRow(
            id: "cardano",
            name: "Cardano",
            symbol: "ADA",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/975/large/cardano.png"),
            price: "$0.48",
            priceRaw: 0.48,
            marketCap: "$16.8B",
            marketCapRaw: 16800000000,
            volume: "$420M",
            volumeRaw: 420000000,
            circulatingSupply: "35.0B ADA",
            ath: "$3.10",
            atl: "$0.017",
            change24h: "-1.10%",
            change24hRaw: -1.10,
            isUp: false,
            sparkline: [0.47, 0.472, 0.471, 0.475, 0.478, 0.482, 0.481, 0.485, 0.483, 0.48],
            currentPriceRaw: 0.0
        ),
        MarketRow(
            id: "dogecoin",
            name: "Dogecoin",
            symbol: "DOGE",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/5/large/dogecoin.png"),
            price: "$0.085",
            priceRaw: 0.085,
            marketCap: "$12.1B",
            marketCapRaw: 12100000000,
            volume: "$720M",
            volumeRaw: 720000000,
            circulatingSupply: "143.8B DOGE",
            ath: "$0.73",
            atl: "$0.0000869",
            change24h: "+3.10%",
            change24hRaw: 3.10,
            isUp: true,
            sparkline: [0.081, 0.082, 0.0825, 0.083, 0.084, 0.085, 0.0845, 0.086, 0.0855, 0.0862],
            currentPriceRaw: 0.0
        ),
        MarketRow(
            id: "solana",
            name: "Solana",
            symbol: "SOL",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/4128/large/solana.png"),
            price: "$98.40",
            priceRaw: 98.40,
            marketCap: "$42.3B",
            marketCapRaw: 42300000000,
            volume: "$1.7B",
            volumeRaw: 1700000000,
            circulatingSupply: "430.1M SOL",
            ath: "$260",
            atl: "$0.50",
            change24h: "-0.22%",
            change24hRaw: -0.22,
            isUp: false,
            sparkline: [94, 95, 96, 97, 98, 99, 98.5, 100, 99.2, 98.4],
            currentPriceRaw: 0.0
        ),
        MarketRow(
            id: "polkadot",
            name: "Polkadot",
            symbol: "DOT",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/12171/large/polkadot.png"),
            price: "$7.10",
            priceRaw: 7.10,
            marketCap: "$9.3B",
            marketCapRaw: 9300000000,
            volume: "$210M",
            volumeRaw: 210000000,
            circulatingSupply: "1.31B DOT",
            ath: "$55",
            atl: "$2.69",
            change24h: "+0.40%",
            change24hRaw: 0.40,
            isUp: true,
            sparkline: [6.8, 6.9, 6.95, 7.0, 7.05, 7.1, 7.08, 7.12, 7.1, 7.11],
            currentPriceRaw: 0.0
        ),
        MarketRow(
            id: "tron",
            name: "TRON",
            symbol: "TRX",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/1094/large/tron-logo.png"),
            price: "$0.106",
            priceRaw: 0.106,
            marketCap: "$9.5B",
            marketCapRaw: 9500000000,
            volume: "$310M",
            volumeRaw: 310000000,
            circulatingSupply: "89.6B TRX",
            ath: "$0.23",
            atl: "$0.001091",
            change24h: "+0.15%",
            change24hRaw: 0.15,
            isUp: true,
            sparkline: [0.102, 0.103, 0.104, 0.105, 0.106, 0.1065, 0.106, 0.107, 0.1068, 0.106],
            currentPriceRaw: 0.0
        )
    ]
}

