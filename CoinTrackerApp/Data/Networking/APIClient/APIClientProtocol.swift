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
    links: .init(
        homepage: ["https://bitcoin.org"],
        blockchainSite: nil,
        subredditUrl: nil
    ),
    image: .init(thumb: nil, small: nil, large: nil),
    marketData: .init(
        currentPrice: ["usd": 42350],
        marketCap: ["usd": 830_000_000_000],
        totalVolume: ["usd": 18_400_000_000],
        circulatingSupply: 19_600_000,
        totalSupply: nil,
        maxSupply: 21_000_000,
        ath: ["usd": 69_000],
        atl: ["usd": 67_000],
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

enum APIClientError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int, Data?)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .httpStatus(let code, _):
            return "Server returned HTTP \(code)."
        case .decoding(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    func request<T: Decodable>(endpoint: CoinGeckoEndpoint) async throws -> T {
        guard let url = endpoint.url else { throw APIClientError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(
            "CG-sYXh9e6nUC5jKE7Ck88EsTF2",
            forHTTPHeaderField: "x-cg-demo-api-key"
        )

        // If you add CoinGecko API key later, you'd add headers here.

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIClientError.httpStatus(http.statusCode, data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIClientError.decoding(error)
        }
    }
}
