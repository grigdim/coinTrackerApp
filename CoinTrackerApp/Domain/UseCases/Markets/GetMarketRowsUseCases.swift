//
//  GetMarketRowsUseCases.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

protocol GetMarketRowsUseCase {
    func execute(
        category: String,
        perPage: Int,
        page: Int,
        ids: [String]?
    ) async throws -> [MarketRow]
}

final class GetMarketRowsUseCaseImpl: GetMarketRowsUseCase {
    private let repository: MarketRowRepository

    init(repository: MarketRowRepository) {
        self.repository = repository
    }

    func execute(
        category: String,
        perPage: Int,
        page: Int,
        ids: [String]? = nil
    ) async throws -> [MarketRow] {
        try await repository.fetchMarketRows(
            category: category,
            perPage: perPage,
            page: page,
            ids: ids
        )
    }
}
