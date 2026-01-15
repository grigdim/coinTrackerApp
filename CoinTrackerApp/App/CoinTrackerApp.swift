//
//  CoinTrackerApp.swift
//  CoinTracker
//
//  Created by Dim Grigoriadis on 11/12/25.
//

import SwiftUI

 @main
struct CoinTrackerApp: App {
    @StateObject private var env = AppEnvironment()
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(env)
        }
    }
}
