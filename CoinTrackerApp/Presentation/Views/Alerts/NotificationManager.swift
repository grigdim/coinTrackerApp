//
//  NotificationManager.swift
//  CoinTrackerApp
//
//  Created by vaitsis.vagias on 31/1/26.
//

import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        registerCategories()
        setDelegate()
    }

    static let categoryId = "PRICE_ALERT_CATEGORY"
    static let actionSnooze1hId = "ALERT_SNOOZE_1H"
    static let actionMarkReadId = "ALERT_MARK_READ"

    weak var alertStore: AlertStore?

    // MARK: - Authorization

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if !granted {
                // You may want to surface this to the user in-app.
                print("Notifications permission not granted.")
            }
        } catch {
            print("Notifications authorization error: \(error)")
        }
    }

    // MARK: - Categories & Actions

    func registerCategories() {
        let snooze = UNNotificationAction(
            identifier: Self.actionSnooze1hId,
            title: "Snooze 1h",
            options: []
        )
        let markRead = UNNotificationAction(
            identifier: Self.actionMarkReadId,
            title: "Mark as Read",
            options: [.authenticationRequired] // optional
        )
        let category = UNNotificationCategory(
            identifier: Self.categoryId,
            actions: [snooze, markRead],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func setDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Scheduling

    func schedulePriceAlertNotification(
        alert: CoinPriceAlert,
        latestPrice: Double
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Price Alert"
        content.body = notificationBody(for: alert, latestPrice: latestPrice)
        content.sound = .default
        content.categoryIdentifier = Self.categoryId
        content.userInfo = [
            "alertId": alert.id.uuidString,
            "coinId": alert.coinId
        ]

        // Deliver immediately
        let request = UNNotificationRequest(
            identifier: "price-alert-\(alert.id.uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Failed to schedule price alert: \(error)")
                return
            }

            Task { @MainActor [weak self] in
                self?.alertStore?.archiveToHistory(
                    alertId: alert.id,
                    triggeredAt: Date(),
                    markUnread: true
                )
            }
        }
    }

    func scheduleSnoozedNotification(
        alertId: UUID,
        coinId: String,
        after seconds: TimeInterval
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Price Alert (Snoozed)"
        content.body = "Reminder for \(coinId)"
        content.sound = .default
        content.categoryIdentifier = Self.categoryId
        content.userInfo = [
            "alertId": alertId.uuidString,
            "coinId": coinId
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(
            identifier: "price-alert-snoozed-\(alertId.uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule snoozed notification: \(error)")
            }
        }
    }

    // MARK: - Helpers

    private func notificationBody(for alert: CoinPriceAlert, latestPrice: Double) -> String {
        let priceString = currencyStringUSD(latestPrice)
        switch alert.type {
        case .above:
            return "\(alert.coinId) is above \(currencyStringUSD(alert.targetPrice)) (now \(priceString))"
        case .below:
            return "\(alert.coinId) is below \(currencyStringUSD(alert.targetPrice)) (now \(priceString))"
        case .percentage:
            return "\(alert.coinId) moved ±\(String(format: "%.2f", alert.targetPrice))% (now \(priceString))"
        }
    }

    private func currencyStringUSD(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "USD"
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 0
        return nf.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

extension NotificationManager {
    // Handle actions
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let alertIdString = userInfo["alertId"] as? String
        let coinId = userInfo["coinId"] as? String
        let alertUUID = alertIdString.flatMap(UUID.init(uuidString:))

        switch response.actionIdentifier {
        case Self.actionSnooze1hId:
            if let uuid = alertUUID, let coinId {
                // 1 hour snooze
                scheduleSnoozedNotification(alertId: uuid, coinId: coinId, after: 3600)
            }
        case Self.actionMarkReadId:
            if let uuid = alertUUID {
                Task { @MainActor [weak self] in
                    self?.alertStore?.markHistoryRead(alertId: uuid)
                }
            }
        default:
            break
        }

        completionHandler()
    }

    // Present notifications while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .list]
    }
}
