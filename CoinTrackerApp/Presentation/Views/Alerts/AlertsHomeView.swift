import SwiftUI

struct AlertsHomeView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedCoinIds, id: \.self) { coinId in
                    Section(header: sectionHeader(coinId: coinId)) {
                        let alerts = env.alertStore.alerts(coinId: coinId)
                        ForEach(alerts) { alert in
                            NavigationLink(
                                destination: CoinAlertsDetailView(
                                    coinId: alert.coinId
                                )
                            ) { alertRow(alert) }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Alerts")
        }
    }

    private var groupedCoinIds: [String] {
        // Unique coinIds from active alerts, sorted
        Array(Set(env.alertStore.active.map { $0.coinId })).sorted()
    }

    private func sectionHeader(coinId: String) -> some View {
        HStack {
            // TODO icon; later we can map coinId to icon URL if available
            Image(systemName: "bitcoinsign.circle")
                .foregroundColor(.orange)
            Text(coinId)
                .font(.headline)
            Spacer()
            let unread = env.alertStore.unreadHistoryCount(coinId: coinId)
            if unread > 0 {
                Label("\(unread)", systemImage: "bell.badge")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }

    private func alertRow(_ alert: CoinPriceAlert) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(alertTitle(for: alert))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(alertSubtitle(for: alert))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { alert.isEnabled },
                    set: { newValue in
                        env.alertStore.toggleEnabled(
                            alertId: alert.id,
                            isEnabled: newValue
                        )
                    }
                )
            )
            .labelsHidden()

            Button(role: .destructive) {
                env.alertStore.delete(alert)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
        }
    }
}
