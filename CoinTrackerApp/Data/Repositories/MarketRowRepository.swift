import Foundation

protocol MarketRowRepository {
    func fetchMarketRows(
        category: String,
        perPage: Int,
        page: Int,
        ids: [String]?
    )
        async throws -> [MarketRow]
}

final class MarketRowRepositoryImpl: MarketRowRepository {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchMarketRows(
        category: String,
        perPage: Int,
        page: Int,
        ids: [String]? = nil
    ) async throws -> [MarketRow] {

        switch category {
        case "trending":
            let endpoint = CoinGeckoEndpoint.trending
            let dto: TrendingResponseDTO = try await apiClient.request(
                endpoint: endpoint
            )
            return dto.coins.map { MarketRowMapper.mapTrending(dto: $0.item) }
        default:
            let endpoint = CoinGeckoEndpoint.markets(
                category: "layer-1",
                perPage: perPage,
                page: page,
                ids: ids
            )
            let dtos: [MarketRowDTO] = try await apiClient.request(
                endpoint: endpoint
            )
            return dtos.map(MarketRowMapper.map)

        }
    }
}
