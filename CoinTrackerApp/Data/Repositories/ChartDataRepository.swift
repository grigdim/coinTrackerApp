import Foundation

protocol ChartDataRepository {
    func fetchChartData(coinId: String, range: ChartRange)
        async throws
        -> [CoinChartPoint]
}

final class ChartDataRepositoryImpl: ChartDataRepository {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchChartData(coinId: String, range: ChartRange)
        async throws
        -> [CoinChartPoint]
    {
        let endpoint = CoinGeckoEndpoint.history(
            id: coinId,
            days: String(range.days)
        )
        let dto: ChartDataDTO = try await apiClient.request(endpoint: endpoint)
        return ChartDataMapper.map(dto: dto)
    }
}
