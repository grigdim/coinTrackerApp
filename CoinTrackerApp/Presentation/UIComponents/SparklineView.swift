//
//  SparklineView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct SparklineView: View {
    let values: [Double]

    var body: some View {
        GeometryReader { geo in
            Path { path in
                guard values.count >= 2 else { return }

                let w = geo.size.width
                let h = geo.size.height

                let minV = values.min() ?? 0
                let maxV = values.max() ?? 0
                let range = max(maxV - minV, 0.000_001)

                func x(_ i: Int) -> CGFloat {
                    w * CGFloat(i) / CGFloat(values.count - 1)
                }

                func y(_ v: Double) -> CGFloat {
                    // Invert because y=0 is top in SwiftUI
                    let normalized = (v - minV) / range
                    return h * (1 - CGFloat(normalized))
                }

                path.move(to: CGPoint(x: x(0), y: y(values[0])))
                for i in 1..<values.count {
                    path.addLine(to: CGPoint(x: x(i), y: y(values[i])))
                }
            }
            .stroke(lineWidth: 0.5)
        }
        .frame(width: 40, height: 30)
        .accessibilityHidden(true)  // keep VoiceOver focused on the row data, not the sparkline
    }
}

#Preview {
    VStack(spacing: 16) {
        SparklineView(values: [1, 2, 1.5, 3, 2.7, 4, 3.5])
        SparklineView(values: [10, 9.5, 9.2, 8.8, 8.2, 7.9, 7.6])
    }
    .padding()
}
