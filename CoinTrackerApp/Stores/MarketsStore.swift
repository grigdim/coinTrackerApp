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
    @Published private(set) var rowsByCategory: [String: [MarketRow]] =
        [:]
    @Published private(set) var fetchedAtByCategory: [String: Date] =
        [:]

    private var lastPageByCategory: [String: Int] = [:]
    private var inFlightNextPage: Set<String> = []

    private let getMarketRows: GetMarketRowsUseCase

    init(getMarketRows: GetMarketRowsUseCase) {
        self.getMarketRows = getMarketRows
    }

    func cachedRows(for category: String) -> [MarketRow] {
        rowsByCategory[category] ?? []
    }

    func fetchedAt(for category: String) -> Date? {
        fetchedAtByCategory[category]
    }

    func refresh(category: String, perPage: Int) async throws
        -> [MarketRow]
    {
        let page = 1
        let rows = try await getMarketRows.execute(
            category: category,
            perPage: perPage,
            page: page,
            ids: nil
        )

        rowsByCategory[category] = rows
        fetchedAtByCategory[category] = Date()
        lastPageByCategory[category] = page
        return rows
    }

    func loadNextPage(category: String, perPage: Int) async throws
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
            page: nextPage,
            ids: nil
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
