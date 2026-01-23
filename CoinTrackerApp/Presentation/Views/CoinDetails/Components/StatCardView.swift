//
//  StatCardView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.08))
        )
    }
}

#Preview {
    StatCardView(title: "Hello", value: "World")
}
