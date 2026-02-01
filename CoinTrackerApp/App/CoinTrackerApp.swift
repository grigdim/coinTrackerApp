import SwiftUI

@main
struct CoinTrackerApp: App {
    @StateObject private var env = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(env)
                .environmentObject(env.alertStore)
                .task {
                    // Share the AlertStore with NotificationManager
                    NotificationManager.shared.alertStore = env.alertStore

                    // Ask for notification permission on first launch
                    await NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
