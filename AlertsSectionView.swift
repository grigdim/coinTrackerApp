    private struct AlertsSectionView: View {
        let coinId: String
        @EnvironmentObject private var env: AppEnvironment
        @State private var showingCreateAlert = false

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {

                // Keep the same business logic
                let alerts = env.alertStore.alerts(coinId: coinId)
                let unread = env.alertStore.unreadHistoryCount(coinId: coinId)

                header(unread: unread)

                if alerts.isEmpty {
                    emptyState
                } else {
                    alertsList(alerts)
                }

                addButton
            }
            .onAppear {
                let alerts = env.alertStore.alerts(coinId: coinId)
                print(
                    "AlertsSectionView alertStore:",
                    ObjectIdentifier(env.alertStore).hashValue,
                    "active:",
                    env.alertStore.active.count,
                    "filtered:",
                    alerts.count,
                    "coinId:",
                    coinId
                )
            }
            .sheet(isPresented: $showingCreateAlert) {
                NewAlertModal(coinId: coinId, alertStore: env.alertStore)
            }
        }

        // MARK: - Header

        private func header(unread: Int) -> some View {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("Alerts")
                    .font(.headline)

                Spacer()

                if unread > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "bell.badge.fill")
                            .imageScale(.small)

                        Text("\(unread)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.orange.opacity(0.12))
                    )
                    .accessibilityLabel("\(unread) unread alert events")
                }
            }
        }

        // MARK: - Empty state

        private var emptyState: some View {
            HStack(spacing: 10) {
                Image(systemName: "bell")
                    .foregroundStyle(.secondary)
                    .imageScale(.medium)

                VStack(alignment: .leading, spacing: 2) {
                    Text("No alerts yet")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Tap **\(Constants.ADD_ALERT)** to create one.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }

        // MARK: - Alerts list

        private func alertsList(_ alerts: [CoinPriceAlert]) -> some View {
            VStack(spacing: 10) {
                ForEach(alerts) { alert in
                    alertRow(alert)
                }
            }
        }

        private func alertRow(_ alert: CoinPriceAlert) -> some View {
            HStack(spacing: 12) {

                VStack(alignment: .leading, spacing: 3) {
                    Text(alertTitle(alert))
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(alertSubtitle(alert))
                        .font(.caption)
                        .foregroundStyle(.secondary)
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

                Button(role: .destructive) {
                    env.alertStore.delete(alert)
                } label: {
                    Image(systemName: "trash")
                        .imageScale(.medium)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Delete alert")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .contentShape(Rectangle())
        }

        // MARK: - Add button

        private var addButton: some View {
            Button {
                showingCreateAlert = true
            } label: {
                Label(Constants.ADD_ALERT, systemImage: "bolt.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .padding(.top, 2)
        }

        // MARK: - Text helpers (same logic)

        private func alertTitle(_ alert: CoinPriceAlert) -> String {
            switch alert.type {
            case .above:
                return "Price above \(CurrencyFormatter.usd(alert.targetPrice))"
            case .below:
                return "Price below \(CurrencyFormatter.usd(alert.targetPrice))"
            case .percentage:
                return
                    "Change ±\(PercentFormatter.twoDecimals(alert.targetPrice))"
            }
        }

        private func alertSubtitle(_ alert: CoinPriceAlert) -> String {
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
    }