//
//  NewAlertModal.swift
//  CoinTrackerApp
//
//  Created by vaitsis.vagias on 1/2/26.
//

import SwiftUI

struct NewHistoryAlertModal: View {

    let coinId: String
    let alertStore: AlertStore
    @Environment(\.dismiss) private var dismiss

    // Local-only UI state for the Picker (visual placeholder, no functionality yet)
    @State private var selectedType: AlertType = .above
    // Visual-only draft target value as text to avoid formatting logic for now
    @State private var targetText: String = ""
    // Visual-only validation error for target input
    @State private var targetError: String?

    // Plain dropdown for coin selection
    enum TrackedCoin: String, CaseIterable, Identifiable {
        case btc, eth, xrp

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .btc: return "BTC"
            case .eth: return "ETH"
            case .xrp: return "XRP"
            }
        }

        // Map to whatever coinId your app uses elsewhere
        var coinId: String {
            switch self {
            case .btc: return "BTC"
            case .eth: return "ETH"
            case .xrp: return "XRP"
            }
        }
    }

    @State private var selectedCoin: String = "--"

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Content Card
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 6) {
                        Text(Constants.NEW_PRICE_ALERT)
                            .font(
                                .system(
                                    .title2,
                                    design: .rounded,
                                    weight: .bold
                                )
                            )
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(Constants.CONFIGURATION_OF_NOTIFICATION)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label(
                                Constants.NOTIFICATION_TARGET,
                                systemImage: "Select Coin"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                            HStack(spacing: 10) {
                                Text("coin")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)

                                Picker("Coin", selection: $selectedCoin) {
                                    ForEach(TrackedCoin.allCases) { coin in
                                        Text(coin.displayName).tag(coin)
                                    }
                                }
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .keyboardType(.decimalPad)
                                .font(
                                    .system(
                                        .title3,
                                        design: .rounded,
                                        weight: .semibold
                                    )
                                )
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous
                                    )
                                    .fill(Color.gray.opacity(0.12))
                                )
                                .overlay(
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous
                                    )
                                    .stroke(
                                        targetError == nil
                                            ? Color.gray.opacity(0.25)
                                            : Color.red.opacity(0.6)
                                    )
                                )
                                .onChange(of: targetText) { newValue in
                                    targetError = AlertTargetInputParser
                                        .validationError(for: newValue)
                                }
                            }

                            // Inline validation message
                            if let targetError {
                                Text(targetError)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }

                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Label(
                                Constants.NOTIFICATION_TARGET,
                                systemImage: "target"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                            HStack(spacing: 10) {
                                Text("$")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)

                                TextField(
                                    Constants.NOTIFICATION_BLANK,
                                    text: $targetText
                                )
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .keyboardType(.decimalPad)
                                .font(
                                    .system(
                                        .title3,
                                        design: .rounded,
                                        weight: .semibold
                                    )
                                )
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous
                                    )
                                    .fill(Color.gray.opacity(0.12))
                                )
                                .overlay(
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous
                                    )
                                    .stroke(
                                        targetError == nil
                                            ? Color.gray.opacity(0.25)
                                            : Color.red.opacity(0.6)
                                    )
                                )
                                .onChange(of: targetText) { newValue in
                                    targetError = AlertTargetInputParser
                                        .validationError(for: newValue)
                                }
                            }

                            // Inline validation message
                            if let targetError {
                                Text(targetError)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }

                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .fill(.ultraThinMaterial)
                        )

                        // Condition row: segmented Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                Constants.NOTIFICATION_CONDITION,
                                systemImage: "arrow.up.arrow.down"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                            Picker(
                                Constants.NOTIFICATION_CONDITION,
                                selection: $selectedType
                            ) {
                                ForEach(AlertType.allCases) { type in
                                    Text(type.label).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .fill(.ultraThinMaterial)
                        )

                        HStack {
                            Label("Status", systemImage: "bell")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Enabled")
                                .font(.headline)
                                .foregroundStyle(.green)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .fill(.ultraThinMaterial)
                        )
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.gray.opacity(0.08))
                    )

                    // Non-functional primary action (visual only)
                    Button {
                        addNewAlert()
                    } label: {
                        Text("Create Alert")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 12,
                                    style: .continuous
                                )
                                .fill(Color.accentColor)
                            )
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.thinMaterial)
                        .shadow(
                            color: Color.black.opacity(0.08),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                )
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        // Recommended detents for a modal editor
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func addNewAlert() {
        guard targetError == nil else { return }
        guard let value = AlertTargetInputParser.parse(targetText) else {
            targetError = "Enter a valid number"
            return
        }
        let addedNewCoin = CoinPriceAlert(
            id: UUID(),
            coinId: coinId,
            targetPrice: value,
            type: selectedType,
            isEnabled: true,
            createdAt: Date(),
            triggeredAt: nil,
            isUnread: false
        )
        alertStore.add(addedNewCoin)
        dismiss()
    }

}
