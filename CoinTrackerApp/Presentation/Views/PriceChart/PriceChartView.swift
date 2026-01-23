import Charts
import SwiftUI

struct PriceChartView: View {
    let coinId: String

    @State private var selectedChartRange: ChartRange = .day
    @StateObject private var viewModel: PriceChartViewModel

    // Scrub selection
    @State private var selectedPoint: CoinChartPoint?

    // Zoom state (X only)
    @State private var visibleXDomain: ClosedRange<Date>?
    @State private var lastMagnification: CGFloat = 1.0

    init(coinId: String) {
        self.coinId = coinId

        let apiClient = APIClient()
        let repository = ChartDataRepositoryImpl(apiClient: apiClient)
        let useCase = GetChartDataUseCaseImpl(repository: repository)

        _viewModel = StateObject(
            wrappedValue: PriceChartViewModel(getChartData: useCase)
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("SelectedChartRange", selection: $selectedChartRange) {
                ForEach(ChartRange.allCases) { chartRange in
                    Text(chartRange.label).tag(chartRange)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedChartRange) { _ in
                // Reset zoom + selection when range changes
                selectedPoint = nil
                visibleXDomain = nil
            }

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
            // New dataset => reset domain to full range
            if let full = fullXDomain(for: viewModelPointsSorted) {
                visibleXDomain = full
            }
            selectedPoint = nil
        }
    }

    // MARK: - Task key

    private var taskKey: String {
        "\(coinId)-\(selectedChartRange.label)"
    }

    // MARK: - ViewState helpers

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

    /// A “signature” that changes when new points arrive (even if count stays same).
    private var viewModelPointsSignature: String {
        let pts = viewModelPointsSorted
        guard let first = pts.first?.date, let last = pts.last?.date else {
            return "empty"
        }
        return
            "\(pts.count)-\(first.timeIntervalSince1970)-\(last.timeIntervalSince1970)"
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Price Chart")
                .font(.headline)

            Spacer()

            if isLoading {
                ProgressView().scaleEffect(0.9)
            }

            Button("Reset") {
                if let full = fullXDomain(for: viewModelPointsSorted) {
                    visibleXDomain = full
                }
                selectedPoint = nil
            }
            .font(.subheadline)
        }
    }

    // MARK: - Container

    @ViewBuilder
    private var chartContainer: some View {
        switch viewModel.state {
        case .idle, .loading:
            placeholderBox(text: "Loading…")

        case .failed(let error):
            placeholderBox(text: error.localizedDescription)

        case .loaded(let points):
            let sorted = points.sorted { $0.date < $1.date }
            if sorted.count < 2 {
                placeholderBox(text: "No data")
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

        let cornerRadius: CGFloat = 16

        return Chart {
            ForEach(sorted) { p in
                LineMark(
                    x: .value("Time", p.date),
                    y: .value("Price", p.value)
                )
                .interpolationMethod(.catmullRom)
            }

            // Just the rule line (tooltip is handled in chartOverlay)
            if let selectedPoint {
                RuleMark(x: .value("Selected", selectedPoint.date))
            }
        }
        .chartXScale(domain: xDomain)
        .chartYScale(domain: yDomain)
        .frame(height: 220)

        // ✅ Clip marks to plot area to stop overflow
        .chartPlotStyle { plotArea in
            plotArea.clipped()
        }

        // Container
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.gray.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.gray.opacity(0.25))
        )

        // ✅ Clip everything (including overlay) to rounded rect
        .clipShape(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )

        .chartOverlay { proxy in
            GeometryReader { geo in
                let plotFrame = geo[proxy.plotAreaFrame]

                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())

                    // Drag = scrub
                    .gesture(
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

                    // Pinch = zoom (X only)
                    .simultaneousGesture(
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
                    )

                // ✅ Tooltip (clamped inside chart)
                if let p = selectedPoint,
                    let xInPlot = proxy.position(forX: p.date)
                {

                    let tooltipWidth: CGFloat = 140
                    let tooltipHeight: CGFloat = 44

                    // Convert plot-relative x to absolute x in GeometryReader
                    let absoluteX = plotFrame.minX + xInPlot

                    // Clamp inside plot area
                    let clampedX = min(
                        max(absoluteX, plotFrame.minX + tooltipWidth / 2),
                        plotFrame.maxX - tooltipWidth / 2
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(formatPrice(p.value))
                            .font(.caption)
                            .fontWeight(.semibold)

                        Text(
                            p.date.formatted(date: .abbreviated, time: .omitted)
                        )
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(
                        width: tooltipWidth,
                        height: tooltipHeight,
                        alignment: .leading
                    )
                    .background(
                        .thinMaterial,
                        in: RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.gray.opacity(0.25))
                    )
                    .position(
                        x: clampedX,
                        y: plotFrame.minY + tooltipHeight / 2 + 4
                    )
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Placeholder

    private func placeholderBox(text: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 220)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3))
                )

            Text(text)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Helpers

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
        let nf = Foundation.NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "USD"
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 0
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
