//
//  GetCoinCategoriesUseCase.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 31/1/26.
//

import Foundation

protocol GetCategoriesUseCase {
    func execute() async throws -> [Category]
}

final class GetCategoriesUseCaseImpl: GetCategoriesUseCase {
    private let repository: CategoriesRepository

    init(repository: CategoriesRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Category] {
        try await repository.fetchCategories()
    }
}
