import SwiftUI

struct SearchFiltersSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var draft: SearchFiltersDraft
    let categories: [Category]
    let onApply: (SearchFilters, String) -> Void
    let onReset: () -> Void

    private let priceMax: Double = 200_000
    private let marketCapMax: Double = 2_000_000_000_000
    private let volumeMax: Double = 200_000_000_000

    init(
        current: SearchFilters,
        currentCategoryId: String,
        categories: [Category],
        onApply: @escaping (SearchFilters, String) -> Void,
        onReset: @escaping () -> Void
    ) {
        _draft = State(
            initialValue: SearchFiltersDraft(
                filters: current,
                categoryId: currentCategoryId
            )
        )
        self.categories = categories
        self.onApply = onApply
        self.onReset = onReset
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Price (USD)") {
                    rangeRow(
                        title: "Min",
                        value: draft.filters.price.lowerBound
                    )
                    rangeRow(
                        title: "Max",
                        value: draft.filters.price.upperBound
                    )

                    let minPrice = 0.0001
                    let maxPrice = priceMax

                    Slider(
                        value: Binding(
                            get: {
                                toLogValue(
                                    draft.filters.price.lowerBound,
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
                                    draft.filters.price.upperBound,
                                    newLower
                                )
                                draft.filters.price = newLower...newUpper
                            }
                        ),
                        in: 0...1
                    )

                    Slider(
                        value: Binding(
                            get: {
                                toLogValue(
                                    draft.filters.price.upperBound,
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
                                    draft.filters.price.lowerBound,
                                    newUpper
                                )
                                draft.filters.price = newLower...newUpper
                            }
                        ),
                        in: 0...1
                    )
                }

                Section("Market Cap (USD)") {
                    rangeRow(
                        title: "Min",
                        value: draft.filters.marketCap.lowerBound
                    )
                    rangeRow(
                        title: "Max",
                        value: draft.filters.marketCap.upperBound
                    )

                    Slider(
                        value: Binding(
                            get: { draft.filters.marketCap.lowerBound },
                            set: { newLower in
                                let clampedLower = max(
                                    0,
                                    min(newLower, marketCapMax)
                                )
                                let newUpper = max(
                                    draft.filters.marketCap.upperBound,
                                    clampedLower
                                )
                                draft.filters.marketCap =
                                    clampedLower...newUpper
                            }
                        ),
                        in: 0...marketCapMax,
                        step: 1
                    )

                    Slider(
                        value: Binding(
                            get: { draft.filters.marketCap.upperBound },
                            set: { newUpper in
                                let clampedUpper = max(
                                    0,
                                    min(newUpper, marketCapMax)
                                )
                                let newLower = min(
                                    draft.filters.marketCap.lowerBound,
                                    clampedUpper
                                )
                                draft.filters.marketCap =
                                    newLower...clampedUpper
                            }
                        ),
                        in: 0...marketCapMax,
                        step: 1
                    )
                }

                Section("Volume (USD)") {
                    rangeRow(
                        title: "Min",
                        value: draft.filters.volume.lowerBound
                    )
                    rangeRow(
                        title: "Max",
                        value: draft.filters.volume.upperBound
                    )

                    Slider(
                        value: Binding(
                            get: { draft.filters.volume.lowerBound },
                            set: { newLower in
                                let clampedLower = max(
                                    0,
                                    min(newLower, volumeMax)
                                )
                                let newUpper = max(
                                    draft.filters.volume.upperBound,
                                    clampedLower
                                )
                                draft.filters.volume = clampedLower...newUpper
                            }
                        ),
                        in: 0...volumeMax,
                        step: 1
                    )

                    Slider(
                        value: Binding(
                            get: { draft.filters.volume.upperBound },
                            set: { newUpper in
                                let clampedUpper = max(
                                    0,
                                    min(newUpper, volumeMax)
                                )
                                let newLower = min(
                                    draft.filters.volume.lowerBound,
                                    clampedUpper
                                )
                                draft.filters.volume = newLower...clampedUpper
                            }
                        ),
                        in: 0...volumeMax,
                        step: 1
                    )
                }

                Section("Category") {
                    Picker("Category", selection: $draft.categoryId) {
                        ForEach(categories) { cat in
                            Text(cat.name).tag(cat.id)
                        }
                    }
                }
                .onAppear {
                    if !categories.contains(where: { $0.id == draft.categoryId }
                    ),
                        let first = categories.first
                    {
                        draft.categoryId = first.id
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        onReset()
                        draft = .default(categoryId: "layer-1")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        onApply(draft.filters, draft.categoryId)
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
        currentCategoryId: "layer-1",
        categories: [
            Category(id: "layer-1", name: "Layer 1"),
            Category(id: "defi", name: "DeFi"),
        ],
        onApply: { _, _ in },
        onReset: {}
    )
}
