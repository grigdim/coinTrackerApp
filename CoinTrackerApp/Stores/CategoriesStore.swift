//
//  CategoriesStore.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 31/1/26.
//

import Combine

@MainActor
final class CategoriesStore: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var isLoading: Bool = false

    private var hasLoadedOnce = false
    private let getCategories: GetCategoriesUseCase

    init(getCategories: GetCategoriesUseCase) {
        self.getCategories = getCategories
    }

    func loadIfNeeded() async {
        guard !hasLoadedOnce else { return }
        await load()
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            categories = try await getCategories.execute()
            hasLoadedOnce = true
        } catch {
            return
        }
    }
}
