//
//  AddViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 24/5/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import UserNotifications

struct PermissionDetails {
    let title: String
    let message: String
}

/// Add view view model.
@MainActor
class AddViewViewModel: ObservableObject {
    /// A boolean value indicating whether a habit is being quit (stopped).
    @Published var isQuittingHabit = true {
        didSet {
            if isQuittingHabit { isStartingHabit = false }
        }
    }
    
    /// A boolean value indicating whether a habit is being started (created).
    @Published var isStartingHabit = false {
        didSet {
            if isStartingHabit { isQuittingHabit = false }
        }
    }
    
    /// The name of the habit being quit or started.
    @Published var habitName = ""
    
    /// What time the habit is usually done.
    @Published var occurrenceTime = Date()
    
    /// What days the habit is usually done.
    @Published var occurrenceDays = Set<Day>()
    
    /// The hours it takes to complete the habit.
    @Published var durationHours = 0
    
    /// The mintues it takes to complete the habit.
    @Published var durationMinutes = 0
    
    /// The input field for the current activity.
    @Published var activityInput = ""
    
    /// A list of the activities the user has added.
    @Published var activities = [String]() // TODO: Change name
    
    /// The reason for quitting or starting the habit being added.
    @Published var reason = ""
    
    /// A reference to the firestore database.
    private lazy var firestore = Firestore.firestore()
    
    /// A boolean value that shows the state of the notifications permissions.
    @Published var showSettingsForPermissions = false
    
    var permissionsDetails: PermissionDetails? {
        didSet {
            if permissionsDetails != nil {
                showSettingsForPermissions = true
            }
        }
    }
}

// MARK: Computed Properties
extension AddViewViewModel {
    /// The total duration the habit takes to complete in seconds.
    var totalDurationSeconds: Int {
        durationHours * 60 + durationMinutes * 60
    }
    
    /// Returns true if all fields have some input.
    var allFieldsFilled: Bool {
        let habitName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        let reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        return !(
            !(isQuittingHabit || isStartingHabit) ||
            habitName.isEmpty ||
            occurrenceDays.isEmpty ||
            !(durationHours == 0 || durationMinutes == 0) ||
            activities.isEmpty ||
            reason.isEmpty
        )
    }
}

// MARK: Functions
extension AddViewViewModel {
    /// Adds the current activity to the list of activities.
    func addActivity() {
        if activityInput.isEmpty { return }
        activities.append(activityInput)
        activityInput = ""
    }
    
    func getNotificationsSettings(center: UNUserNotificationCenter) async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }
    
    /// Adds the habit to the firestore database.
    func addHabit(session: UserSession) async {
        precondition(session.currentUser != nil, "User is not logged in")
        assert(allFieldsFilled, "All fields not filled in")
        guard let user = session.currentUser else {
            return
        }
        let habitRef = firestore
            .collection("habits")
            .document(user.uid)
            .collection("habits")
            .document()
        let habit = Habit(
            id: habitRef.documentID,
            isQuittingHabit: isQuittingHabit,
            isStartingHabit: isStartingHabit,
            name: habitName,
            occurrenceTime: occurrenceTime,
            occurrenceDays: occurrenceDays,
            durationHours: durationHours,
            durationMinutes: durationMinutes,
            activities: activities,
            reason: reason
        )
        do {
            try habitRef.setData(from: habit)
            // TODO: Move to some notifications manager?
            let center = UNUserNotificationCenter.current()
            let hasPermission = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            if !hasPermission {
                permissionsDetails = PermissionDetails(
                    title: "Allow reminders for habits",
                    message: "Please allow the notifications for this app," +
                        " so that it can remind you when you need to complete a certain habit"
                )
                return
            }
            let settings = await getNotificationsSettings(center: center)
            guard (settings.authorizationStatus == .authorized ||
                   settings.authorizationStatus == .provisional) else {
                return
            }
            
            if settings.lockScreenSetting == .enabled ||
                settings.notificationCenterSetting == .enabled ||
                settings.alertSetting == .enabled ||
                settings.authorizationStatus == .authorized
            {
                // create notification type
                let content = UNMutableNotificationContent()
                content.title = habit.isQuittingHabit ? "Quitting \(habit.name)" : "Starting \(habit.name)"
                content.subtitle = "this is the subtitle"
                content.sound = .default
                content.body = habit.isQuittingHabit ?
                "You are quitting \(habit.name), try to do this instead: \(habit.activities.randomElement()!)" :
                "You are starting \(habit.name). Make sure to do it to help the habit stick"
                
                for day in habit.occurrenceDays {
                    // Trigger
                    var dateComponents = DateComponents()
                    dateComponents.weekday = day.rawValue + 1
                    let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: habit.occurrenceTime)
                    dateComponents.hour = timeComponents.hour ?? 0
                    dateComponents.minute = (timeComponents.minute ?? 0)
                    #if EMULATORS
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                    #else
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    #endif
                    
                    // Request
                    let id = UUID().uuidString
                    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                    try await center.add(request)
                    
                    // check up trigger?
                    let reminderContent = UNMutableNotificationContent()
                    reminderContent.title = "Write journal entry"
                    reminderContent.sound = .default
                    reminderContent.body = "You should have finished \(habit.name), how do you feel?"
                    reminderContent.userInfo = [
                        "USER_ID": user.uid,
                        "HABIT_ID": habit.id
                    ]
                    reminderContent.categoryIdentifier = "JOURNAL_ENTRY"
                    
                    var reminderDateComponents = DateComponents()
                    reminderDateComponents.weekday = day.rawValue + 1
                    reminderDateComponents.hour = timeComponents.hour ?? 0 + habit.durationHours
                    reminderDateComponents.minute = (timeComponents.minute ?? 0) + habit.durationMinutes
                    #if EMULATORS
                    let reminderTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 6, repeats: false)
                    #else
                    let reminderTrigger = UNCalendarNotificationTrigger(dateMatching: reminderDateComponents, repeats: true)
                    #endif
                    
                    // Request
                    let reminderID = UUID().uuidString
                    let reminderRequest = UNNotificationRequest(identifier: reminderID, content: reminderContent, trigger: reminderTrigger)
                    try await center.add(reminderRequest)
                }
                // schedule notification
            } else {
                let content = UNMutableNotificationContent()
                content.sound = .default
                // TODO: implement
            }
        } catch {
            print("Error in \(#function): \(error)")
        }
    }
    
    /// Removes the activity from the list.
    func removeActivity(activity: String) {
        guard let index = activities.firstIndex(of: activity) else {
            preconditionFailure("Activity: \(activity) isn't in the array of activities.")
        }
        activities.remove(at: index)
    }
}
