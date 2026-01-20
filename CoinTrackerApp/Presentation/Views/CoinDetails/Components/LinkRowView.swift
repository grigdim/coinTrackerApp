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
        if let url {
            Link(destination: url) {
                rowContent(trailingText: url.host ?? url.absoluteString)
            }
        } else {
            rowContent(trailingText: "Not available")
                .foregroundColor(.secondary)
        }
    }

    private func rowContent(trailingText: String) -> some View {
        HStack {
            Text(title)

            Spacer()

            Text(trailingText)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundColor(.blue)

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.08))
        )
    }
}

#Preview {
    LinkRowView(
        title: "Website",
        url: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png")
    )
}
