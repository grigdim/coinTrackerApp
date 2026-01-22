import Foundation

protocol CoinRepository {
    func fetchCoinDetailsById(_ id: String) async throws -> CoinDetails
}

final class CoinRepositoryImpl: CoinRepository {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchCoinDetailsById(_ id: String) async throws -> CoinDetails {
        let endpoint = CoinGeckoEndpoint.coinDetail(id: id)
        let dto: CoinDetailDTO = try await apiClient.request(endpoint: endpoint)
        return CoinDetailsMapper.map(dto: dto)
    }
}
