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

                            Text(alertTitle(for: alert))

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

}
