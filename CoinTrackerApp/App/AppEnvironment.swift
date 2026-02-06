import Combine
import SwiftUI

@MainActor
final class AppEnvironment: ObservableObject {
    let alertStore: AlertStore

    private var cancellable: AnyCancellable?

    init(alertStore: AlertStore) {
        self.alertStore = alertStore

        // Forward store changes so views observing AppEnvironment update.
        cancellable = alertStore.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
}
