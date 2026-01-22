//
//  GetCoinDetailsUseCase.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

protocol GetCoinDetailUseCase {
    func execute(id: String) async throws -> CoinDetails
}

final class GetCoinDetailUseCaseImpl: GetCoinDetailUseCase {
    private let repository: CoinRepository

    init(repository: CoinRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> CoinDetails {
        try await repository.fetchCoinDetailsById(id)
    }
}
