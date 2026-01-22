//
//  APIClientProtocol.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(endpoint: CoinGeckoEndpoint) async throws -> T
}

let mockCoinDetailDTO = CoinDetailDTO(
    id: "bitcoin",
    symbol: "btc",
    name: "Bitcoin",
    description: .init(en: "Mock description"),
    links: .init(homepage: ["https://bitcoin.org"], blockchainSite: nil, subredditUrl: nil),
    image: .init(thumb: nil, small: nil, large: nil),
    marketData: .init(
        currentPrice: ["usd": 42350],
        marketCap: ["usd": 830_000_000_000],
        totalVolume: ["usd": 18_400_000_000],
        circulatingSupply: 19_600_000,
        totalSupply: nil,
        maxSupply: 21_000_000,
        ath: ["usd": 69_000],
        atl: ["usd": 67],
        priceChange24h: 1200,
        priceChangePercentage24h: 3.42,
        priceChangePercentage7d: 5.1,
        priceChangePercentage30d: -2.3,
        priceChangePercentage1y: 80.0
    )
)

final class MockApiClient: APIClientProtocol {
    func request<T: Decodable>(endpoint: CoinGeckoEndpoint) async throws -> T {
        switch endpoint {
        case .coinDetail:
            let dto = mockCoinDetailDTO
            guard let value = dto as? T else {
                throw URLError(.cannotParseResponse)
            }
            return value
        default:
            throw URLError(.unsupportedURL)
        }
    }
}

