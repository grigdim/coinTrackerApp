//
//  CategoriesRepository.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 31/1/26.
//

protocol CategoriesRepository {
    func fetchCategories() async throws -> [Category]
}

final class CategoriesRepositoryImpl: CategoriesRepository {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchCategories() async throws -> [Category] {
        let dto: [CategoryDTO] = try await apiClient.request(endpoint: .categoriesList)
        return dto.map(CategoryMapper.map)
    }
}
