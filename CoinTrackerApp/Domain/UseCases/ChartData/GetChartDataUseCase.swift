//
//  GetChartDataUseCase.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 23/1/26.
//

import Foundation

protocol GetChartDataUseCase {
    func execute(coinId id: String, range: ChartRange) async throws
        -> [CoinChartPoint]
}

final class GetChartDataUseCaseImpl: GetChartDataUseCase {
    private let repository: ChartDataRepository

    init(repository: ChartDataRepository) {
        self.repository = repository
    }

    func execute(coinId id: String, range: ChartRange) async throws
        -> [CoinChartPoint]
    {
        return try await repository.fetchChartData(
            coinId: id,
            range: range
        )
    }
}
