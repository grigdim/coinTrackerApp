import SwiftUI

struct CoinAlertsDetailView: View {
    let coinId: String
    @EnvironmentObject var alertStore: AlertStore

    var body: some View {
        List {
            Section(header: Text(coinId)) {
                let alerts = alertStore.alerts(coinId: coinId)
                if alerts.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "bell")
                            .foregroundColor(.secondary)
                            .imageScale(.small)
                        Text(Constants.NO_ALERTS)
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                    .listRowInsets(
                        EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
                    )
                } else {
                    ForEach(alerts) { alert in
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(title(for: alert))
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                Text(subtitle(for: alert))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 8)
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
                            .toggleStyle(.switch)
                            .scaleEffect(0.85)
                            Button(role: .destructive) {
                                alertStore.delete(alert)
                            } label: {
                                Image(systemName: "trash")
                                    .imageScale(.small)
                            }
                            .buttonStyle(.borderless)
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 4)
                        .listRowInsets(
                            EdgeInsets(
                                top: 4,
                                leading: 12,
                                bottom: 4,
                                trailing: 12
                            )
                        )
                    }
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 32)
        .navigationTitle("Alerts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    seedExampleAlert()
                } label: {
                    Label("Seed", systemImage: "bolt.fill")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    CoinAlertsHistoryView(coinId: coinId)
                } label: {
                    Image(systemName: "clock")
                }
            }
        }
    }

    private func seedExampleAlert() {
        let sample = CoinPriceAlert(
            id: UUID(),
            coinId: coinId,
            targetPrice: 100.0,
            type: .above,
            isEnabled: true,
            createdAt: Date(),
            triggeredAt: nil,
            isUnread: false
        )
        alertStore.add(sample)
    }

    private func title(for alert: CoinPriceAlert) -> String {
        switch alert.type {
        case .above: return "Price above \(currency(alert.targetPrice))"
        case .below: return "Price below \(currency(alert.targetPrice))"
        case .percentage: return "Change ±\(percent(alert.targetPrice))"
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
