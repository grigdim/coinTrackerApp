//
//  StoresContainer.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 30/1/26.
//

import Combine
import SwiftUI

@MainActor
final class StoresContainer: ObservableObject {

    let marketsStore: MarketsStore

    init(marketsStore: MarketsStore) {
        self.marketsStore = marketsStore
    }
}
