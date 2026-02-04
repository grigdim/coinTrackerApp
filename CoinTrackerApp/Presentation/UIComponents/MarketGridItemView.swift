import SwiftUI

struct MarketGridItemView: View {
    let coin: MarketRow
    let onAppear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {

                Spacer()

                AsyncImage(url: coin.iconURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    default:
                        Image(systemName: "bitcoinsign.circle")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.symbol)
                        .font(.headline)
                        .lineLimit(1)

                    Text(coin.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.price)
                        .font(.headline)
                        .lineLimit(1)

                    Text(coin.change24h)
                        .font(.caption)
                        .foregroundColor(coin.isUp ? .green : .red)
                        .lineLimit(1)

                }
                Spacer()
                SparklineView(values: coin.sparkline)
                    .frame(width: 60)
            }

        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.gray.opacity(0.10))
        )
        .id(coin.id)
        .onAppear(perform: onAppear)
    }
}

#Preview {
    MarketGridItemView(coin: .sampleRows[0]) {}
}
