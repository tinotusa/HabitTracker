//
//  NotificationCenterDelegate.swift
//  Habit Tracker
//
//  Created by Tino on 28/9/2022.
//

import SwiftUI
import FirebaseFirestore
import os

struct NotificationActionIdentifiers {
    static let accept = "ACCEPT_JOURNAL_ENTRY_ACTION"
    static let deny = "DENY_JOURNAL_ENTRY_ACTION"
    static let journalEntry = "JOURNAL_ENTRY"
}

final class NotificationCenterDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private(set) var notificationManager = NotificationManager()
    private var logger = Logger(subsystem: "com.tinotusa.HabitTracker", category: "NotificationCenterDelegate")
    private lazy var firestore = Firestore.firestore()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        let center = UNUserNotificationCenter.current()
        
        let acceptJournalEntryAction = UNNotificationAction(
            identifier: NotificationActionIdentifiers.accept,
            title: "Completed task",
            options: [.foreground]
        )
        
        let denyJournalEntryAction = UNNotificationAction(
            identifier: NotificationActionIdentifiers.deny,
            title: "Did not complete task",
            options: [.foreground]
        )
        
        let journalEntryCategory = UNNotificationCategory(
            identifier: NotificationActionIdentifiers.journalEntry,
            actions: [acceptJournalEntryAction, denyJournalEntryAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        center.setNotificationCategories([journalEntryCategory])
        center.delegate = self
        logger.debug("Successfully finished application function.")
        return true
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        logger.debug("Starting to get permissions")
        // TODO: Request permission?
        return [.banner, .sound, .list]
    }
    
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        logger.debug("Starting did receive notification function.")
        let userInfo = response.notification.request.content.userInfo
        
        guard let userID = userInfo["USER_ID"] as? String else {
            logger.error("Error. UserInfo dict has no user id")
            return
        }
        
        guard let habitID = userInfo["HABIT_ID"] as? String else {
            logger.error("Error. UserInfo dict has no habit id")
            return
        }
    
        switch response.actionIdentifier {
        case NotificationActionIdentifiers.accept:
            logger.debug("Accepted action for habit with id: \(habitID)")
            do {
                let documentRef = firestore
                    .collection("habits")
                    .document(userID)
                    .collection("habits")
                    .document(habitID)
                
                let snapshot = try await documentRef.getDocument()
                let habit = try snapshot.data(as: Habit.self)
                notificationManager.currentHabit = habit
                logger.debug("Successfully set current habit to habit with id: \(habit.id)")
            } catch {
                logger.error("Error failed to accept notification action. \(error)")
            }
        case NotificationActionIdentifiers.deny:
            logger.debug("Denied notification action. Nothing needs to be done for this.")
            // nothing should be done (no database entry)
            break
        default:
            // TODO: move dupe code to func
            logger.debug("Default notification action.")
            let documentRef = firestore
                .collection("habits")
                .document(userID)
                .collection("habits")
                .document(habitID)
            
            do {
                let snapshot = try await documentRef.getDocument()
                let habit = try snapshot.data(as: Habit.self)
                notificationManager.currentHabit = habit
            } catch {
                logger.error("Error failed default notifcation action. \(error)")
            }
            break
        }
    }
}
