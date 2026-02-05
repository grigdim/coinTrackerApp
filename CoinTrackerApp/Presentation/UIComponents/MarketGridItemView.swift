import SwiftUI

struct MarketGridItemView: View {
    let coin: MarketRow
    let onAppear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            footer
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onAppear(perform: onAppear)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            icon

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.symbol.uppercased())
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(coin.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }

    private var footer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.price)
                    .font(.headline)
                    .monospacedDigit()
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(
                        systemName: coin.isUp
                            ? "arrow.up.right" : "arrow.down.right"
                    )
                    .font(.caption2.weight(.semibold))

                    Text(coin.change24h)
                        .font(.caption)
                        .monospacedDigit()
                        .lineLimit(1)
                }
                .foregroundStyle(coin.isUp ? .green : .red)
            }

            Spacer(minLength: 0)

            SparklineView(values: coin.sparkline)
                .frame(width: 64, height: 24)
                .accessibilityHidden(true)
        }
    }

    private var icon: some View {
        AsyncImage(url: coin.iconURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .controlSize(.small)

            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()

            case .failure:
                Image(systemName: "bitcoinsign.circle")
                    .foregroundStyle(.secondary)

            @unknown default:
                Image(systemName: "bitcoinsign.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 28, height: 28)
        .padding(6)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.thinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
    }

    private var accessibilityText: Text {
        Text(
            "\(coin.name), \(coin.price), \(coin.isUp ? "up" : "down") \(coin.change24h)"
        )
    }
}

#Preview {
    MarketGridItemView(coin: .sampleRows[0]) {}
        .padding()
}
