//
//  CoinDetails.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

struct CoinDetails: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let symbol: String

    // Images
    let iconURL: URL?

    // Price info (already formatted for UI)
    let price: String
    let change24h: String
    let isUp: Bool

    // Market stats
    let marketCap: String
    let volume: String
    let circulatingSupply: String
    let ath: String
    let atl: String

    // Chart
    let sparkline: [Double]  // from history endpoint

    // About
    let description: String?

    // Links (UI-friendly)
    let websiteURL: URL?
    let explorerURL: URL?
    let subredditURL: URL?

    var toMarketRow: MarketRow {
        MarketRow(
            id: id,
            name: name,
            symbol: symbol,
            iconURL: iconURL,
            price: price,
            priceRaw: MoneyStringFormatter.parseMoneyToDouble(price) ?? 0.0,
            marketCap: marketCap,
            marketCapRaw: MoneyStringFormatter.parseMoneyToDouble(marketCap)
                ?? 0.0,
            volume: volume,
            volumeRaw: MoneyStringFormatter.parseMoneyToDouble(volume) ?? 0.0,
            circulatingSupply: circulatingSupply,
            ath: ath,
            atl: atl,
            change24h: change24h,
            change24hRaw: PercentFormatter.parse(change24h) ?? 0.0,
            isUp: isUp,
            sparkline: sparkline,
            currentPriceRaw: 0.0
        )
    }
    // MARK: - Hashable
    static func == (lhs: CoinDetails, rhs: CoinDetails) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension CoinDetails {
    static let sampleCoins: [CoinDetails] = [
        CoinDetails(
            id: "bitcoin",
            name: "Bitcoin",
            symbol: "BTC",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
            ),
            price: "$43,210.12",
            change24h: "+2.45%",
            isUp: true,
            marketCap: "$847.2B",
            volume: "$21.3B",
            circulatingSupply: "19.4M BTC",
            ath: "$69,044",
            atl: "$67",
            sparkline: [
                41200, 41800, 41550, 42010, 42500, 43000, 42800, 43300, 43200,
                43550,
            ],
            description: "Bitcoin is a decentralized digital currency.",
            websiteURL: URL(string: "https://bitcoin.org"),
            explorerURL: URL(string: "https://www.blockchain.com/explorer"),
            subredditURL: URL(string: "https://www.reddit.com/r/Bitcoin/")
        ),
        CoinDetails(
            id: "ethereum",
            name: "Ethereum",
            symbol: "ETH",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/279/large/ethereum.png"
            ),
            price: "$2,310.85",
            change24h: "+1.12%",
            isUp: true,
            marketCap: "$277.4B",
            volume: "$8.9B",
            circulatingSupply: "120.2M ETH",
            ath: "$4,878",
            atl: "$0.43",
            sparkline: [
                2240, 2265, 2250, 2288, 2300, 2315, 2298, 2325, 2310, 2332,
            ],
            description:
                "Ethereum is a decentralized platform for smart contracts.",
            websiteURL: URL(string: "https://ethereum.org"),
            explorerURL: URL(string: "https://etherscan.io"),
            subredditURL: URL(string: "https://www.reddit.com/r/ethereum/")
        ),
        CoinDetails(
            id: "tether",
            name: "Tether",
            symbol: "USDT",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/325/large/Tether-logo.png"
            ),
            price: "$1.00",
            change24h: "+0.01%",
            isUp: true,
            marketCap: "$95.0B",
            volume: "$35.1B",
            circulatingSupply: "95.0B USDT",
            ath: "$1.32",
            atl: "$0.57",
            sparkline: [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
            description: "Tether is a stablecoin pegged to the US Dollar.",
            websiteURL: URL(string: "https://tether.to"),
            explorerURL: URL(string: "https://etherscan.io/token/USDT"),
            subredditURL: nil
        ),
        CoinDetails(
            id: "binancecoin",
            name: "BNB",
            symbol: "BNB",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/825/large/binance-coin-logo.png"
            ),
            price: "$312.40",
            change24h: "-0.54%",
            isUp: false,
            marketCap: "$48.2B",
            volume: "$1.2B",
            circulatingSupply: "153.9M BNB",
            ath: "$690",
            atl: "$0.03",
            sparkline: [305, 307, 306, 309, 311, 313, 312, 314, 313, 312],
            description: "BNB powers the Binance ecosystem.",
            websiteURL: URL(string: "https://www.binance.com"),
            explorerURL: URL(string: "https://bscscan.com"),
            subredditURL: URL(string: "https://www.reddit.com/r/binance/")
        ),
        CoinDetails(
            id: "ripple",
            name: "XRP",
            symbol: "XRP",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/44/large/xrp.png"
            ),
            price: "$0.57",
            change24h: "+0.83%",
            isUp: true,
            marketCap: "$30.8B",
            volume: "$1.1B",
            circulatingSupply: "53.7B XRP",
            ath: "$3.40",
            atl: "$0.0028",
            sparkline: [
                0.55, 0.552, 0.553, 0.558, 0.561, 0.565, 0.563, 0.569, 0.568,
                0.57,
            ],
            description: "XRP is a digital asset built for payments.",
            websiteURL: URL(string: "https://ripple.com/xrp"),
            explorerURL: URL(string: "https://xrpscan.com"),
            subredditURL: URL(string: "https://www.reddit.com/r/Ripple/")
        ),
        CoinDetails(
            id: "cardano",
            name: "Cardano",
            symbol: "ADA",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/975/large/cardano.png"
            ),
            price: "$0.48",
            change24h: "-1.10%",
            isUp: false,
            marketCap: "$16.8B",
            volume: "$420M",
            circulatingSupply: "35.0B ADA",
            ath: "$3.10",
            atl: "$0.017",
            sparkline: [
                0.47, 0.472, 0.471, 0.475, 0.478, 0.482, 0.481, 0.485, 0.483,
                0.48,
            ],
            description: "Cardano is a proof-of-stake blockchain platform.",
            websiteURL: URL(string: "https://cardano.org"),
            explorerURL: URL(string: "https://cardanoscan.io"),
            subredditURL: URL(string: "https://www.reddit.com/r/cardano/")
        ),
        CoinDetails(
            id: "dogecoin",
            name: "Dogecoin",
            symbol: "DOGE",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/5/large/dogecoin.png"
            ),
            price: "$0.085",
            change24h: "+3.10%",
            isUp: true,
            marketCap: "$12.1B",
            volume: "$720M",
            circulatingSupply: "143.8B DOGE",
            ath: "$0.73",
            atl: "$0.0000869",
            sparkline: [
                0.081, 0.082, 0.0825, 0.083, 0.084, 0.085, 0.0845, 0.086,
                0.0855, 0.0862,
            ],
            description:
                "Dogecoin is a cryptocurrency featuring a likeness of the Shiba Inu dog.",
            websiteURL: URL(string: "https://dogecoin.com"),
            explorerURL: URL(string: "https://blockchair.com/dogecoin"),
            subredditURL: URL(string: "https://www.reddit.com/r/dogecoin/")
        ),
        CoinDetails(
            id: "solana",
            name: "Solana",
            symbol: "SOL",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/4128/large/solana.png"
            ),
            price: "$98.40",
            change24h: "-0.22%",
            isUp: false,
            marketCap: "$42.3B",
            volume: "$1.7B",
            circulatingSupply: "430.1M SOL",
            ath: "$260",
            atl: "$0.50",
            sparkline: [94, 95, 96, 97, 98, 99, 98.5, 100, 99.2, 98.4],
            description:
                "Solana is a high-performance blockchain supporting builders around the world.",
            websiteURL: URL(string: "https://solana.com"),
            explorerURL: URL(string: "https://explorer.solana.com"),
            subredditURL: URL(string: "https://www.reddit.com/r/solana/")
        ),
        CoinDetails(
            id: "polkadot",
            name: "Polkadot",
            symbol: "DOT",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/12171/large/polkadot.png"
            ),
            price: "$7.10",
            change24h: "+0.40%",
            isUp: true,
            marketCap: "$9.3B",
            volume: "$210M",
            circulatingSupply: "1.31B DOT",
            ath: "$55",
            atl: "$2.69",
            sparkline: [6.8, 6.9, 6.95, 7.0, 7.05, 7.1, 7.08, 7.12, 7.1, 7.11],
            description:
                "Polkadot enables cross-blockchain transfers of any type of data or asset.",
            websiteURL: URL(string: "https://polkadot.network"),
            explorerURL: URL(string: "https://polkascan.io"),
            subredditURL: URL(string: "https://www.reddit.com/r/polkadot/")
        ),
        CoinDetails(
            id: "tron",
            name: "TRON",
            symbol: "TRX",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/1094/large/tron-logo.png"
            ),
            price: "$0.106",
            change24h: "+0.15%",
            isUp: true,
            marketCap: "$9.5B",
            volume: "$310M",
            circulatingSupply: "89.6B TRX",
            ath: "$0.23",
            atl: "$0.001091",
            sparkline: [
                0.102, 0.103, 0.104, 0.105, 0.106, 0.1065, 0.106, 0.107, 0.1068,
                0.106,
            ],
            description:
                "TRON is a blockchain-based decentralized operating system.",
            websiteURL: URL(string: "https://tron.network"),
            explorerURL: URL(string: "https://tronscan.org"),
            subredditURL: URL(string: "https://www.reddit.com/r/Tronix/")
        ),
        CoinDetails(
            id: "chainlink",
            name: "Chainlink",
            symbol: "LINK",
            iconURL: URL(
                string:
                    "https://assets.coingecko.com/coins/images/877/large/chainlink-new-logo.png"
            ),
            price: "$15.22",
            change24h: "-0.90%",
            isUp: false,
            marketCap: "$8.5B",
            volume: "$450M",
            circulatingSupply: "556.8M LINK",
            ath: "$52.70",
            atl: "$0.1263",
            sparkline: [
                14.8, 14.9, 15.0, 15.2, 15.3, 15.4, 15.25, 15.35, 15.22, 15.18,
            ],
            description: "Chainlink is a decentralized oracle network.",
            websiteURL: URL(string: "https://chain.link"),
            explorerURL: URL(string: "https://etherscan.io/token/LINK"),
            subredditURL: URL(string: "https://www.reddit.com/r/Chainlink/")
        ),
    ]
}
