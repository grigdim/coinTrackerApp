//
//  PortfolioPieChart.swift
//  CoinTrackerApp
//
//  Created by antonis.darmis on 30/1/26.
//

import SwiftUI

struct PortfolioPieChart: View {
    let assets: [PortfolioAsset]
    
    var body: some View {
        Canvas { context, size in
            let total = assets.reduce(0) { $0 + $1.currentValue }
            guard total > 0 else { return }
            
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            var startAngle = Angle.degrees(-90)
            
            let colors: [Color] = [.blue, .purple, .pink, .orange, .yellow, .green, .cyan, .indigo]
            
            for (index, asset) in assets.enumerated() {
                let value = asset.currentValue
                let angle = Angle.degrees(360 * (value / total))
                let endAngle = startAngle + angle
                
                let path = Path { p in
                    p.move(to: center)
                    p.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                }
                
                context.fill(path, with: .color(colors[index % colors.count]))
                startAngle = endAngle
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
