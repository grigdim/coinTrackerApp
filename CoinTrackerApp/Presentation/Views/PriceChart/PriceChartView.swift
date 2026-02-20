import Charts
import SwiftUI

struct PriceChartView: View {
    let coinId: String

    @State private var selectedChartRange: ChartRange = .day
    @StateObject private var viewModel: PriceChartViewModel

    @State private var selectedPoint: CoinChartPoint?

    @State private var visibleXDomain: ClosedRange<Date>?
    @State private var lastMagnification: CGFloat = 1.0

    private let cardCornerRadius: CGFloat = 16
    private let cardFill = Color.gray.opacity(0.08)
    private let cardStroke = Color.gray.opacity(0.18)

    private static let priceFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "USD"
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 0
        return nf
    }()

    init(coinId: String, alertStore: AlertStore) {
        self.coinId = coinId

        let apiClient = APIClient()
        let repository = ChartDataRepositoryImpl(apiClient: apiClient)
        let useCase = GetChartDataUseCaseImpl(repository: repository)

        _viewModel = StateObject(
            wrappedValue: PriceChartViewModel(
                getChartData: useCase,
                alertStore: alertStore
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            rangePicker
            header
            chartContainer
        }
        .task(id: taskKey) {
            await viewModel.loadChartRange(
                for: coinId,
                range: selectedChartRange
            )
        }
        .onChange(of: viewModelPointsSignature) { _ in
            if let full = fullXDomain(for: viewModelPointsSorted) {
                visibleXDomain = full
            }
            selectedPoint = nil
        }
    }

    private var taskKey: String {
        "\(coinId)-\(selectedChartRange.label)"
    }

    private var isLoading: Bool {
        if case .loading = viewModel.state { return true }
        return false
    }

    private var viewModelPoints: [CoinChartPoint] {
        if case .loaded(let pts) = viewModel.state { return pts }
        return []
    }

    private var viewModelPointsSorted: [CoinChartPoint] {
        viewModelPoints.sorted { $0.date < $1.date }
    }

    private var viewModelPointsSignature: String {
        let pts = viewModelPointsSorted
        guard let first = pts.first?.date, let last = pts.last?.date else {
            return "empty"
        }
        return
            "\(pts.count)-\(first.timeIntervalSince1970)-\(last.timeIntervalSince1970)"
    }

    // MARK: - UI pieces

    private var rangePicker: some View {
        Picker("SelectedChartRange", selection: $selectedChartRange) {
            ForEach(ChartRange.allCases) { chartRange in
                Text(chartRange.label).tag(chartRange)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 2)
        .onChange(of: selectedChartRange) { _ in
            // Reset zoom + selection when range changes
            selectedPoint = nil
            visibleXDomain = nil
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("Price Chart")
                .font(.headline)

            Spacer()

            if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .transition(.opacity)
            }

            Button {
                if let full = fullXDomain(for: viewModelPointsSorted) {
                    visibleXDomain = full
                }
                selectedPoint = nil
            } label: {
                Text("Reset")
            }
            .font(.subheadline)
            .buttonStyle(.borderless)
        }
        .foregroundStyle(.primary)
    }

    @ViewBuilder
    private var chartContainer: some View {
        switch viewModel.state {
        case .idle, .loading:
            placeholderCard(
                title: "Loading…",
                systemImage: "chart.line.uptrend.xyaxis"
            )

        case .failed(let error):
            placeholderCard(
                title: "Couldn’t load chart",
                subtitle: error.localizedDescription,
                systemImage: "exclamationmark.triangle"
            )

        case .loaded(let points):
            let sorted = points.sorted { $0.date < $1.date }
            if sorted.count < 2 {
                placeholderCard(
                    title: "No data",
                    subtitle: "Try another range.",
                    systemImage: "waveform.path.ecg"
                )
            } else {
                chart(points: sorted)
            }
        }
    }

    // MARK: - Chart

    private func chart(points sorted: [CoinChartPoint]) -> some View {
        let fullX =
            fullXDomain(for: sorted) ?? (sorted.first!.date...sorted.last!.date)
        let xDomain = visibleXDomain ?? fullX

        let visiblePoints = sorted.filter { xDomain.contains($0.date) }
        let yDomain = yDomain(for: visiblePoints)

        return Chart {
            ForEach(sorted) { p in
                LineMark(
                    x: .value("Time", p.date),
                    y: .value("Price", p.value)
                )
                .interpolationMethod(.catmullRom)
            }

            // Selection visuals (UI only)
            if let selectedPoint {
                RuleMark(x: .value("Selected", selectedPoint.date))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.secondary)

                PointMark(
                    x: .value("Selected Time", selectedPoint.date),
                    y: .value("Selected Price", selectedPoint.value)
                )
                .symbolSize(40)
            }
        }
        .chartXScale(domain: xDomain)
        .chartYScale(domain: yDomain)
        .frame(height: 220)
        .chartPlotStyle { plotArea in
            plotArea.clipped()
        }
        .background(cardBackground)
        .overlay(cardBorder)
        .clipShape(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
        )

        .chartOverlay { proxy in
            GeometryReader { geo in
                let plotFrame = geo[proxy.plotAreaFrame]

                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        // NOTE: minimumDistance 0 = instant scrub; if pinch still feels hard,
                        // change this to 5.
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let xPos = value.location.x - plotFrame.origin.x
                                if let date: Date = proxy.value(atX: xPos) {
                                    selectedPoint = nearestPoint(
                                        to: date,
                                        inSorted: sorted
                                    )
                                }
                            }
                    )

                if let p = selectedPoint,
                    let xInPlot = proxy.position(forX: p.date)
                {
                    tooltip(
                        price: formatPrice(p.value),
                        date: p.date,
                        plotFrame: plotFrame,
                        xInPlot: xInPlot
                    )
                }
            }
        }
        .simultaneousGesture(zoomGesture(fullX: fullX))
        .padding(.vertical, 4)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
            .fill(cardFill)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
            .stroke(cardStroke)
    }

    // MARK: - Gestures

    private func zoomGesture(fullX: ClosedRange<Date>) -> some Gesture {
        MagnificationGesture()
            .onChanged { magnification in
                let current = visibleXDomain ?? fullX
                let delta = magnification / lastMagnification
                lastMagnification = magnification

                visibleXDomain = zoomX(
                    domain: current,
                    fullDomain: fullX,
                    by: delta
                )
            }
            .onEnded { _ in
                lastMagnification = 1.0
            }
    }

    // MARK: - Tooltip

    private func tooltip(
        price: String,
        date: Date,
        plotFrame: CGRect,
        xInPlot: CGFloat
    ) -> some View {
        let tooltipWidth: CGFloat = 160
        let tooltipHeight: CGFloat = 52

        let absoluteX = plotFrame.minX + xInPlot
        let clampedX = min(
            max(absoluteX, plotFrame.minX + tooltipWidth / 2),
            plotFrame.maxX - tooltipWidth / 2
        )

        return VStack(alignment: .leading, spacing: 4) {
            Text(price)
                .font(.caption)
                .fontWeight(.semibold)

            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(width: tooltipWidth, height: tooltipHeight, alignment: .leading)
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(cardStroke)
        )
        .position(
            x: clampedX,
            y: plotFrame.minY + tooltipHeight / 2 + 6
        )
    }

    // MARK: - Placeholder

    private func placeholderCard(
        title: String,
        subtitle: String? = nil,
        systemImage: String
    ) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(cardBackground)
        .overlay(cardBorder)
        .clipShape(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
        )
    }

    // MARK: - Helpers (business logic intact)

    private func fullXDomain(for points: [CoinChartPoint]) -> ClosedRange<Date>?
    {
        guard let first = points.first?.date,
            let last = points.last?.date,
            first < last
        else { return nil }
        return first...last
    }

    private func yDomain(for points: [CoinChartPoint]) -> ClosedRange<Double> {
        guard let minV = points.min(by: { $0.value < $1.value })?.value,
            let maxV = points.max(by: { $0.value < $1.value })?.value
        else {
            return 0...1
        }

        if minV == maxV {
            let pad = max(1.0, abs(minV) * 0.01)
            return (minV - pad)...(maxV + pad)
        }

        let padding = (maxV - minV) * 0.10
        return (minV - padding)...(maxV + padding)
    }

    private func nearestPoint(to date: Date, inSorted points: [CoinChartPoint])
        -> CoinChartPoint?
    {
        points.min(by: {
            abs($0.date.timeIntervalSince(date))
                < abs($1.date.timeIntervalSince(date))
        })
    }

    private func zoomX(
        domain: ClosedRange<Date>,
        fullDomain: ClosedRange<Date>,
        by delta: CGFloat
    ) -> ClosedRange<Date> {
        let currentSeconds = domain.upperBound.timeIntervalSince(
            domain.lowerBound
        )
        let center = domain.lowerBound.addingTimeInterval(currentSeconds / 2)

        let minSeconds: TimeInterval = 60 * 10
        let maxSeconds: TimeInterval = fullDomain.upperBound.timeIntervalSince(
            fullDomain.lowerBound
        )

        var newSeconds = currentSeconds / Double(delta)
        newSeconds = max(minSeconds, min(maxSeconds, newSeconds))

        let newLower = center.addingTimeInterval(-newSeconds / 2)
        let newUpper = center.addingTimeInterval(newSeconds / 2)

        let clampedLower = max(newLower, fullDomain.lowerBound)
        let clampedUpper = min(newUpper, fullDomain.upperBound)

        guard clampedLower < clampedUpper else { return domain }
        return clampedLower...clampedUpper
    }

    private func formatPrice(_ value: Double) -> String {
        Self.priceFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
