//
//  StatCardView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct StatCardViewMockModel {
    let title: String
    let value: String
}

struct StatCardView: View {
    
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.08))
        )
    }
}

#Preview {
    StatCardView(title: "Hello", value: "World")
}
