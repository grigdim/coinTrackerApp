import Foundation

protocol MarketRowRepository {
    func fetchMarketRows(category: MarketCategory, perPage: Int, page: Int)
        async throws -> [MarketRow]
}

final class MarketRowRepositoryImpl: MarketRowRepository {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchMarketRows(
        category: MarketCategory,
        perPage: Int,
        page: Int
    ) async throws -> [MarketRow] {

        switch category {
        case .top100, .gainers, .losers:
            let endpoint = CoinGeckoEndpoint.markets(
                perPage: perPage,
                page: page
            )
            let dtos: [MarketRowDTO] = try await apiClient.request(
                endpoint: endpoint
            )
            return dtos.map(MarketRowMapper.map)

        case .trending:
            let endpoint = CoinGeckoEndpoint.trending
            let dto: TrendingResponseDTO = try await apiClient.request(
                endpoint: endpoint
            )
            return dto.coins.map { MarketRowMapper.mapTrending(dto: $0.item) }
        }
    }
}
