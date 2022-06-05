//
//  Habit_TrackerApp.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import SwiftUI
import Firebase
import FirebaseFunctions
import FirebaseAuth
import UserNotifications

@MainActor
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
    
    static var notificationCenter = UNUserNotificationCenter.current()
    
    static func request(
        identifier: String,
        title: String,
        body: String,
        dateComponents: DateComponents,
        repeats: Bool,
        categoryIdentifier: String? = nil,
        userInfo: [AnyHashable: Any]? = nil
    ) -> UNNotificationRequest {
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
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        return request
    }
    
    static func add(request: UNNotificationRequest) async -> Bool {
        do {
            try await notificationCenter.add(request)
            return true
        } catch {
            print("\(error)")
        }
        return false
    }
}

class NotificationCenterDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var notificationManager = NotificationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let center = UNUserNotificationCenter.current()
        
        let acceptJournalEntryAction = UNNotificationAction(
            identifier: "ACCEPT_JOURNAL_ENTRY_ACTION",
            title: "Completed task",
            options: [.foreground]
        )
        
        let denyJournalEntryAction = UNNotificationAction(
            identifier: "DENY_JOURNAL_ENTRY_ACTION",
            title: "Did not complete task",
            options: []
        )
        
        let journalEntryCategory = UNNotificationCategory(
            identifier: "JOURNAL_ENTRY",
            actions: [acceptJournalEntryAction, denyJournalEntryAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        center.setNotificationCategories([journalEntryCategory])
        center.delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        // TODO: Request permission?
        [.banner, .sound, .list]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        guard let userID = userInfo["USER_ID"] as? String else {
            print("has no user id")
            return
        }
        guard let habitID = userInfo["HABIT_ID"] as? String else {
            print("has no habit id")
            return
        }
    
        switch response.actionIdentifier {
        case "ACCEPT_JOURNAL_ENTRY_ACTION":
            print("accepted for habit: \(habitID)")
            let firestore = Firestore.firestore()
            let documentRef = firestore
                .collection("habits")
                .document(userID)
                .collection("habits")
                .document(habitID)
            
            do {
                let query = try await documentRef.getDocument()
                let habit = try query.data(as: Habit.self)
                notificationManager.currentHabit = habit
            } catch {
                print("Error in \(#function)\n\(error)")
            }
        case "DENY_JOURNAL_ENTRY_ACTION":
            // nothing should be done (no database entry)
            break
        default:
            // TODO: move dupe code to func
            let firestore = Firestore.firestore()
            let documentRef = firestore
                .collection("habits")
                .document(userID)
                .collection("habits")
                .document(habitID)
            
            do {
                let query = try await documentRef.getDocument()
                let habit = try query.data(as: Habit.self)
                notificationManager.currentHabit = habit
            } catch {
                print("\(error)")
            }
            break
        }
    }
}

@main
struct Habit_TrackerApp: App {
    @StateObject var userSession = UserSession()
    @UIApplicationDelegateAdaptor private var notificationDelegate: NotificationCenterDelegate
    
    init() {
        FirebaseApp.configure()
        #if EMULATORS
        print("******* RUNNING ON EMULATORS *******")
        Functions.functions(region: "australia-southeast1").useEmulator(withHost: "localhost", port: 5001)
        Auth.auth().useEmulator(withHost: "localhost", port: 9099)

        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isPersistenceEnabled = false
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        #elseif DEBUG
        print("******* RUNNING ON LIVE FIREBASE *******")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userSession.isSignedIn {
                    MainView()
                        .environmentObject(userSession)
                        .environmentObject(notificationDelegate.notificationManager)
                } else {
                    LoginView()
                        .environmentObject(userSession)
                }
            }
        }
        
    }
}
