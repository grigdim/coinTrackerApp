//
//  GetMarketRowsUseCases.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

protocol GetMarketRowsUseCase {
    func execute(
        category: MarketCategory,
        perPage: Int,
        page: Int
    ) async throws -> [MarketRow]
}

final class GetMarketRowsUseCaseImpl: GetMarketRowsUseCase {
    private let repository: MarketRowRepository

    init(repository: MarketRowRepository) {
        self.repository = repository
    }

    func execute(
        category: MarketCategory,
        perPage: Int,
        page: Int
    ) async throws -> [MarketRow] {
        try await repository.fetchMarketRows(
            category: category,
            perPage: perPage,
            page: page
        )
    }
}
