//
//  GetCoinDetailsUseCase.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

protocol GetCoinDetailsUseCase {
    func execute(for id: String) async throws -> CoinDetails
}

final class GetCoinDetailsUseCaseImpl: GetCoinDetailsUseCase {
    private let repository: CoinRepository

    init(repository: CoinRepository) {
        self.repository = repository
    }

    func execute(for id: String) async throws -> CoinDetails {
        try await repository.fetchCoinDetailsById(for: id)
    }
}
