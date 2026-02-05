//
//  LinkRowView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct LinkRowView: View {
    let title: String
    let url: URL?

    var body: some View {
        Group {
            if let url {
                Link(destination: url) {
                    rowContent(
                        trailingText: displayHost(for: url),
                        isEnabled: true
                    )
                }
            } else {
                rowContent(
                    trailingText: "Not available",
                    isEnabled: false
                )
            }
        }
    }

    private func rowContent(
        trailingText: String,
        isEnabled: Bool
    ) -> some View {
        HStack(spacing: 12) {

            Text(title)
                .foregroundColor(.primary)

            Spacer(minLength: 8)

            Text(trailingText)
                .lineLimit(1)
                .truncationMode(.middle)
                .font(.subheadline)
                .foregroundColor(
                    isEnabled ? .accentColor : .secondary
                )

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(Color(.tertiaryLabel))
                .opacity(isEnabled ? 1 : 0.4)
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .contentShape(Rectangle())  // full row tappable
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            isEnabled
                ? "\(title), opens link"
                : "\(title), not available"
        )
    }

    private func displayHost(for url: URL) -> String {
        if let host = url.host {
            return host.replacingOccurrences(of: "www.", with: "")
        }
        return url.absoluteString
    }
}

