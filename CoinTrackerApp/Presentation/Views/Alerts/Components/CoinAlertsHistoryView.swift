//
//  CoinAlertsHistoryView.swift
//  CoinTrackerApp
//
//  Created by vaitsis.vagias on 1/2/26.
//

import SwiftUI

struct CoinAlertsHistoryView: View {
    let coinId: String

    @EnvironmentObject var alertStore: AlertStore

    var body: some View {

        List {

            Section(header: Text(coinId)) {

                let items = alertStore.history(coinId: coinId)

                if items.isEmpty {

                    HStack(spacing: 6) {

                        Image(systemName: "bell")

                            .foregroundColor(.secondary)

                            .imageScale(.small)

                        Text(Constants.NO_ALERTS)

                            .foregroundColor(.secondary)

                            .font(.footnote)

                    }

                } else {

                    ForEach(items) { alert in

                        VStack(alignment: .leading, spacing: 2) {

                            Text(title(for: alert))

                                .font(.footnote)

                                .fontWeight(.semibold)

                            Text(historySubtitle(for: alert))

                                .font(.caption2)

                                .foregroundColor(.secondary)

                        }

                        .padding(.vertical, 4)

                    }

                }

            }

        }

        .navigationTitle("History")

        .navigationBarTitleDisplayMode(.inline)

    }

    private func title(for alert: CoinPriceAlert) -> String {

        switch alert.type {

        case .above: return "Price above \(currency(alert.targetPrice))"

        case .below: return "Price below \(currency(alert.targetPrice))"

        case .percentage: return "Change ±\(percent(alert.targetPrice))"

        }

    }

    private func historySubtitle(for alert: CoinPriceAlert) -> String {

        var parts: [String] = []

        if let t = alert.triggeredAt {

            parts.append(
                "Triggered " + t.formatted(date: .abbreviated, time: .shortened)
            )

        }

        if alert.isUnread { parts.append("Unread") }

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
