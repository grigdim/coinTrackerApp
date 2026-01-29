import SwiftUI

struct SearchFiltersSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var draft: SearchFilters
    let onApply: (SearchFilters) -> Void
    let onReset: () -> Void

    private let priceMax: Double = 200_000
    private let marketCapMax: Double = 3_000_000_000_000
    private let volumeMax: Double = 300_000_000_000

    init(
        current: SearchFilters,
        onApply: @escaping (SearchFilters) -> Void,
        onReset: @escaping () -> Void
    ) {
        _draft = State(initialValue: current)
        self.onApply = onApply
        self.onReset = onReset
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Price (USD)") {
                    rangeRow(title: "Min", value: draft.price.lowerBound)
                    rangeRow(title: "Max", value: draft.price.upperBound)

                    let minPrice = 0.0001
                    let maxPrice = priceMax

                    Slider(
                        value: Binding(
                            get: {
                                toLogValue(
                                    draft.price.lowerBound,
                                    minValue: minPrice,
                                    maxValue: maxPrice
                                )
                            },
                            set: { t in
                                let newLower =
                                    fromLogValue(
                                        t,
                                        minValue: minPrice,
                                        maxValue: maxPrice
                                    )
                                let newUpper = max(
                                    draft.price.upperBound,
                                    newLower
                                )
                                draft.price = newLower...newUpper
                            }
                        ),
                        in: 0...1
                    )

                    Slider(
                        value: Binding(
                            get: {
                                toLogValue(
                                    draft.price.upperBound,
                                    minValue: minPrice,
                                    maxValue: maxPrice
                                )
                            },
                            set: { t in
                                let newUpper =
                                    fromLogValue(
                                        t,
                                        minValue: minPrice,
                                        maxValue: maxPrice
                                    )
                                let newLower = min(
                                    draft.price.lowerBound,
                                    newUpper
                                )
                                draft.price = newLower...newUpper
                            }
                        ),
                        in: 0...1
                    )
                }

                Section("Market Cap (USD)") {
                    rangeRow(title: "Min", value: draft.marketCap.lowerBound)
                    rangeRow(title: "Max", value: draft.marketCap.upperBound)

                    Slider(
                        value: Binding(
                            get: { draft.marketCap.lowerBound },
                            set: { newLower in
                                let clampedLower = max(
                                    0,
                                    min(newLower, marketCapMax)
                                )
                                let newUpper = max(
                                    draft.marketCap.upperBound,
                                    clampedLower
                                )
                                draft.marketCap = clampedLower...newUpper
                            }
                        ),
                        in: 0...marketCapMax,
                        step: 1
                    )

                    Slider(
                        value: Binding(
                            get: { draft.marketCap.upperBound },
                            set: { newUpper in
                                let clampedUpper = max(
                                    0,
                                    min(newUpper, marketCapMax)
                                )
                                let newLower = min(
                                    draft.marketCap.lowerBound,
                                    clampedUpper
                                )
                                draft.marketCap = newLower...clampedUpper
                            }
                        ),
                        in: 0...marketCapMax,
                        step: 1
                    )
                }

                Section("Volume (USD)") {
                    rangeRow(title: "Min", value: draft.volume.lowerBound)
                    rangeRow(title: "Max", value: draft.volume.upperBound)

                    Slider(
                        value: Binding(
                            get: { draft.volume.lowerBound },
                            set: { newLower in
                                let clampedLower = max(
                                    0,
                                    min(newLower, volumeMax)
                                )
                                let newUpper = max(
                                    draft.volume.upperBound,
                                    clampedLower
                                )
                                draft.volume = clampedLower...newUpper
                            }
                        ),
                        in: 0...volumeMax,
                        step: 1
                    )

                    Slider(
                        value: Binding(
                            get: { draft.volume.upperBound },
                            set: { newUpper in
                                let clampedUpper = max(
                                    0,
                                    min(newUpper, volumeMax)
                                )
                                let newLower = min(
                                    draft.volume.lowerBound,
                                    clampedUpper
                                )
                                draft.volume = newLower...clampedUpper
                            }
                        ),
                        in: 0...volumeMax,
                        step: 1
                    )
                }

                //                Section("Category") {
                //                    Picker(
                //                        "Category",
                //                        selection: Binding(
                //                            get: { draft.category ?? "All" },
                //                            set: { newValue in
                //                                draft.category =
                //                                    (newValue == "All" ? nil : newValue)
                //                            }
                //                        )
                //                    ) {
                //                        Text("All").tag("All")
                //                        Text("Layer 1").tag("layer-1")
                //                        Text("DeFi").tag("decentralized-finance-defi")
                //                        Text("Meme").tag("meme-token")
                //                    }
                //                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        onReset()
                        draft = .default
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        onApply(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func rangeRow(title: String, value: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(formatUSDAdaptive(value))
                .foregroundColor(.secondary)
        }
    }

    private func toLogValue(_ price: Double, minValue: Double, maxValue: Double)
        -> Double
    {
        let clamped = Swift.max(minValue, Swift.min(price, maxValue))
        let minLog = log10(minValue)
        let maxLog = log10(maxValue)
        let valueLog = log10(clamped)
        return (valueLog - minLog) / (maxLog - minLog)  // 0...1
    }

    private func fromLogValue(_ t: Double, minValue: Double, maxValue: Double)
        -> Double
    {
        let minLog = log10(minValue)
        let maxLog = log10(maxValue)
        let valueLog = minLog + t * (maxLog - minLog)
        return pow(10, valueLog)
    }

    private func formatUSDAdaptive(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "USD"
        nf.minimumFractionDigits = 0

        switch value {
        case 0..<0.01:
            nf.maximumFractionDigits = 6
        case 0.01..<1:
            nf.maximumFractionDigits = 4
        default:
            nf.maximumFractionDigits = 2
        }

        return nf.string(from: NSNumber(value: value)) ?? "—"
    }
}

#Preview {
    SearchFiltersSheet(
        current: .default,
        onApply: { _ in },
        onReset: {}
    )
}
