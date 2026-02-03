import SwiftUI

struct CoinAlertsDetailView: View {
    let coinId: String
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        List {
            Section(header: Text(coinId)) {
                let alerts = env.alertStore.alerts(coinId: coinId)
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
                                Text(alertTitle(for: alert))
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                Text(alertSubtitle(for: alert))
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
                                        env.alertStore.toggleEnabled(
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
                                env.alertStore.delete(alert)
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
        env.alertStore.add(sample)
    }
}
