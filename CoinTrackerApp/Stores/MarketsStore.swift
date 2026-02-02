//
//  MarketsStore.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 30/1/26.
//

import Combine
import Foundation

@MainActor
final class MarketsStore: ObservableObject {
    @Published private(set) var rowsByCategory: [MarketCategory: [MarketRow]] =
        [:]
    @Published private(set) var fetchedAtByCategory: [MarketCategory: Date] =
        [:]

    private var lastPageByCategory: [MarketCategory: Int] = [:]
    private var inFlightNextPage: Set<MarketCategory> = []

    private let getMarketRows: GetMarketRowsUseCase

    init(getMarketRows: GetMarketRowsUseCase) {
        self.getMarketRows = getMarketRows
    }

    func cachedRows(for category: MarketCategory) -> [MarketRow] {
        rowsByCategory[category] ?? []
    }

    func fetchedAt(for category: MarketCategory) -> Date? {
        fetchedAtByCategory[category]
    }

    func refresh(category: MarketCategory, perPage: Int) async throws
        -> [MarketRow]
    {
        let page = 1
        let rows = try await getMarketRows.execute(
            category: category,
            perPage: perPage,
            page: page
        )

        rowsByCategory[category] = rows
        fetchedAtByCategory[category] = Date()
        lastPageByCategory[category] = page
        return rows
    }

    func loadNextPage(category: MarketCategory, perPage: Int) async throws
        -> [MarketRow]
    {
        guard !inFlightNextPage.contains(category) else {
            return cachedRows(for: category)
        }
        inFlightNextPage.insert(category)
        defer { inFlightNextPage.remove(category) }

        let nextPage = (lastPageByCategory[category] ?? 1) + 1
        let newRows = try await getMarketRows.execute(
            category: category,
            perPage: perPage,
            page: nextPage
        )

        // merge + dedupe by id
        var merged = rowsByCategory[category] ?? []
        let existingIds = Set(merged.map(\.id))
        merged.append(
            contentsOf: newRows.filter { !existingIds.contains($0.id) }
        )

        rowsByCategory[category] = merged
        fetchedAtByCategory[category] = Date()
        lastPageByCategory[category] = nextPage
        return merged
    }
}
