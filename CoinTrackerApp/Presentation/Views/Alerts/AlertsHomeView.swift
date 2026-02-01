import SwiftUI

struct AlertsHomeView: View {
    @EnvironmentObject var alertStore: AlertStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedCoinIds, id: \.self) { coinId in
                    Section(header: sectionHeader(coinId: coinId)) {
                        let alerts = alertStore.alerts(coinId: coinId)
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
        Array(Set(alertStore.active.map { $0.coinId })).sorted()
    }


    private func sectionHeader(coinId: String) -> some View {
        HStack {
            // TODO icon; later we can map coinId to icon URL if available
            Image(systemName: "bitcoinsign.circle")
                .foregroundColor(.orange)
            Text(coinId)
                .font(.headline)
            Spacer()
            let unread = alertStore.unreadHistoryCount(coinId: coinId)
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
                Text(title(for: alert))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle(for: alert))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { alert.isEnabled },
                    set: { newValue in
                        alertStore.toggleEnabled(
                            alertId: alert.id,
                            isEnabled: newValue
                        )
                    }
                )
            )
            .labelsHidden()

            Button(role: .destructive) {
                alertStore.delete(alert)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
        }
    }


    private func title(for alert: CoinPriceAlert) -> String {
        switch alert.type {
        case .above:
            return "Price above \(currency(alert.targetPrice))"
        case .below:
            return "Price below \(currency(alert.targetPrice))"
        case .percentage:
            return "Change ±\(percent(alert.targetPrice))"
        }
    }

    private func subtitle(for alert: CoinPriceAlert) -> String {
        var parts: [String] = []
        parts.append(
            "Created "
                + alert.createdAt.formatted(
                    date: .abbreviated,
                    time: .shortened
                )
        )
        if alert.isEnabled == false {
            parts.append("Disabled")
        }
        return parts.joined(separator: " • ")
    }

    private func currency(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "USD"
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 0
        return nf.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    private func percent(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 0
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
