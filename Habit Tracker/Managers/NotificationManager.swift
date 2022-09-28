//
//  NotificationManager.swift
//  Habit Tracker
//
//  Created by Tino on 28/9/2022.
//

import SwiftUI
import UserNotifications
import os

final class NotificationManager: ObservableObject {
    @Published var currentHabit: Habit? {
        didSet {
            if currentHabit != nil {
                navigationBindingActive = true
            } else {
                navigationBindingActive = false
            }
        }
    }
    @Published var navigationBindingActive = false
    private var logger = Logger(subsystem: "com.tinotusa.HabitTracker", category: "NotificationManager")
    private lazy var notificationCenter = UNUserNotificationCenter.current()
}

// MARK: Public
extension NotificationManager {
    func getNotificationsSettings() async -> UNNotificationSettings {
        logger.debug("Getting notification settings")
        return await withCheckedContinuation { continuation in
            notificationCenter.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }
    
    func hasPermissions() async -> Bool {
        logger.debug("Checking is app has notification permissions.")
        let settings = await getNotificationsSettings()
        let hasPermission = (
            settings.lockScreenSetting          == .enabled ||
            settings.notificationCenterSetting  == .enabled ||
            settings.alertSetting               == .enabled ||
            settings.authorizationStatus        == .authorized
        )
        if hasPermission {
            logger.debug("Notification manager has permissions.")
            return hasPermission
        }
        logger.debug("Notifiation manager does not have persmission.")
        return hasPermission
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async {
        logger.debug("Requesting authorization for permissions.")
        do {
            try await notificationCenter.requestAuthorization(options: options)
            logger.debug("Successfully got authorization for permissions.")
        } catch {
            logger.error("Error failed to get authorization. \(error)")
        }
    }
    
    func request(
        identifier: String,
        title: String,
        body: String,
        dateComponents: DateComponents,
        repeats: Bool,
        categoryIdentifier: String? = nil,
        userInfo: [AnyHashable: Any]? = nil
    ) -> UNNotificationRequest {
        
        logger.debug("Creating request for notification.")
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        if categoryIdentifier != nil {
            content.categoryIdentifier = categoryIdentifier!
        }
        if userInfo != nil {
            content.userInfo = userInfo!
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        // for testing
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        logger.debug("Successfully created notification request.")
        return request
    }
    
    func add(request: UNNotificationRequest) async -> Bool {
        logger.debug("Adding notification request to system.")
        await requestAuthorization(options: [.alert, .badge, .sound, .provisional])
        do {
            try await notificationCenter.add(request)
            logger.debug("Successfully added notification request to system.")
            return true
        } catch {
            logger.error("Error failed to add notification requst to system. \(error)")
        }
        return false
    }
    
    func removePendingNotifications(withIdentifiers ids: [String]) {
        logger.debug("Starting to remove notifications with ids: \(ids).")
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
        logger.debug("Successfully removed notifications with ids: \(ids).")
    }
}
