import SwiftUI

@main
struct CoinTrackerApp: App {
    @StateObject private var stores = AppStores()
    @StateObject private var env = AppEnvironment(alertStore: AlertStore())

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(stores)
                .task {
                    await stores.categories.loadIfNeeded()
                }
                .environmentObject(env)
                .task {
                    // Share the AlertStore with NotificationManager
                    NotificationManager.shared.alertStore = env.alertStore

                    // Ask for notification permission on first launch
                    await NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
