//
//  AppEnvironment.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Combine
import SwiftUI

@MainActor
final class AppEnvironment: ObservableObject {
    // Strong reference so NotificationManager’s weak ref won’t be nil
    let alertStore: AlertStore

    init(alertStore: AlertStore) {
        self.alertStore = alertStore
    }
}
