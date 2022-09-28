//
//  AddHabitViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 24/5/2022.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import UserNotifications
import SwiftUI
import os

struct PermissionDetails {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
}


enum HabitState: CaseIterable, Codable, Identifiable {
    case quitting
    case starting
    
    var id: Self { self }
    var label: LocalizedStringKey {
        switch self {
        case .quitting: return "Quitting"
        case .starting: return "Starting"
        }
    }
}

/// Add view view model.
@MainActor
final class AddHabitViewViewModel: ObservableObject {
    /// A boolean value indicating whether a habit is being quit (stopped).
    @Published var habitState = HabitState.quitting
    
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
    @Published var activities = [Activity]() // TODO: Change name
    
    /// The reason for quitting or starting the habit being added.
    @Published var reason = ""
    
    /// A reference to the firestore database.
    private lazy var firestore = Firestore.firestore()
    
    /// A boolean value that shows the state of the notifications permissions.
    @Published var showSettingsForPermissions = false
    
    /// Holds the current state of permissions.
    var permissionsDetails: PermissionDetails? {
        didSet {
            if permissionsDetails != nil {
                showSettingsForPermissions = true
            }
        }
    }
    
    /// A boolean value indicating the view had an error.
    @Published var didError = false
    
    /// Holds the error information.
    @Published var errorDetails: ErrorDetails? {
        didSet {
            if errorDetails != nil {
                didError = true
            }
        }
    }
    /// A boolean value indicating the views loading state
    @Published var isLoading = false
    /// A boolean value indicating whether or not to show an action notification.
    @Published var showActionNotification = false
    
    /// The text to be displayed when the question mark button is pressed.
    enum HelpText: LocalizedStringKey {
        case name = "The name of the habit"
        case occurrenceTime = "The time you usually do this habit."
        case ooccurrenceDays = "The days when you usually do this habit."
        case duration = "The length of time it takes to do this habit."
        case activities = "Things you want to replace this habit with."
        case reason = "What is your reason for quitting this habit?"
    }
    
    /// The prompt for the reason `TextField`.
    let reasonPrompt = LocalizedStringKey("Reason")
    /// The prompt for the activity input `TextField`.
    let activityInputPrompt = LocalizedStringKey("Activity")
    /// The prompt for the habit name `TextField`.
    let habitNamePrompt = LocalizedStringKey("Name")
    
    private var logger = Logger(subsystem: "com.tinotusa.HabitTracker", category: "AddHabitViewViewModel")
}

// MARK: Computed Properties
extension AddHabitViewViewModel {
    var timeInputLabel: LocalizedStringKey {
        if habitState == .quitting { return "When do you usually do this?" }
        return "When do you want to do this?"
    }
    
    var dayInputlabel: LocalizedStringKey {
        if habitState == .quitting { return "What days do you usually this?" }
        return "On what days to you want to do this?"
    }
    
    var durationInputLabel: LocalizedStringKey {
        if habitState == .quitting { return "How long does this usually last?" }
        return "How long do you want to do this for?"
    }
    
    /// The total duration the habit takes to complete in seconds.
    var totalDurationSeconds: Int {
        durationHours * 60 + durationMinutes * 60
    }
    
    /// Returns true if all fields have some input.
    var allFieldsFilled: Bool {
        let habitName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        let reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if habitName.isEmpty { return false }
        if occurrenceDays.isEmpty { return false }
        if (durationHours == 0 && durationMinutes == 0) { return false }
        if activities.isEmpty { return false }
        if reason.isEmpty { return false }
        
        return true
    }
}

// MARK: - InputFieldChecks conformance
extension AddHabitViewViewModel: InputFieldChecks {
    func checkNameLength(name: String) {
        habitName = Constants.checkNameLength(name: name)
    }
    
    func checkActivityInputLength(activity: String) {
        activityInput = Constants.checkActivityInputLength(activity: activity)
    }
    
    func checkReasonInputLength(reason: String) {
        self.reason = Constants.checkReasonInputLength(reason: reason)
    }
}

// MARK: Functions
extension AddHabitViewViewModel {
    /// Adds the current activity to the list of activities.
    func addActivity() {
        if activityInput.isEmpty { return }
        if activities.count < Constants.maxActivitiesPerHabit {
            activities.append(Activity(name: activityInput))
        }
        activityInput = ""
    }
    
    /// Adds the habit to the firestore database.
    @MainActor
    func addHabit(session: UserSession) async {
        logger.debug("Starting to add habit.")
        withAnimation(.spring()) {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }
        assert(allFieldsFilled, "All fields not filled in")
        guard let user = session.currentUser else {
            logger.error("User is not logged in.")
            return
        }
        
        let habitRef = firestore
            .collection("habits")
            .document(user.uid)
            .collection("habits")
            .document()
        
        var habit = Habit(
            id: habitRef.documentID,
            createdBy: user.uid,
            habitState: habitState,
            name: habitName,
            occurrenceTime: occurrenceTime,
            occurrenceDays: occurrenceDays,
            durationHours: durationHours,
            durationMinutes: durationMinutes,
            activities: activities,
            reason: reason
        )
        
        let notificationManager = NotificationManager()
        
        await notificationManager.requestAuthorization(options: [.alert, .badge, .sound])
        
        if await !notificationManager.hasPermissions() {
            permissionsDetails = PermissionDetails(
                title: "Allow reminders for habits",
                message: "Please allow the notifications for this app, so that it can remind you when you need to complete a certain habit"
            )
            logger.debug("Asking for permissions.")
        }
        
        let title = habit.habitState == .quitting ? "Quitting \(habit.name)" : "Starting \(habit.name)"
        let body = habit.habitState == .quitting ?
        "You are quitting \(habit.name), try to do this instead: \(habit.activities.randomElement()!.name)" :
        "You are starting \(habit.name). Make sure to do it to help the habit stick"
        
        let reminderTitle = "Write journal entry"
        let reminderBody = "You should have finished \(habit.name), how do you feel?"
        let reminderUserInfo = [
            "USER_ID": user.uid,
            "HABIT_ID": habit.id
        ]
        let reminderCategoryIdentifier = NotificationActionIdentifiers.journalEntry
        
        for day in habit.occurrenceDays {
            var dateComponents = DateComponents()
            dateComponents.weekday = day.rawValue + 1
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: habit.occurrenceTime)
            dateComponents.hour = timeComponents.hour ?? 0
            dateComponents.minute = (timeComponents.minute ?? 0)
            
            logger.debug("The components are: \(dateComponents)")
            let id = UUID().uuidString
            habit.localNotificationIDs.append(id)
            let request = notificationManager.request(
                identifier: id,
                title: title,
                body: body,
                dateComponents: dateComponents,
                repeats: true
            )
            
            let successfulNotificationAdd = await notificationManager.add(request: request)
            
            var reminderDateComponents = DateComponents()
            reminderDateComponents.weekday = day.rawValue + 1
            reminderDateComponents.hour = timeComponents.hour ?? 0 + habit.durationHours
            reminderDateComponents.minute = (timeComponents.minute ?? 0) + habit.durationMinutes
            
            let reminderID = UUID().uuidString
            habit.localReminderNotificationIDs.append(reminderID)
            let reminderRequest = notificationManager.request(
                identifier: reminderID,
                title: reminderTitle,
                body: reminderBody,
                dateComponents: reminderDateComponents,
                repeats: true,
                categoryIdentifier: reminderCategoryIdentifier,
                userInfo: reminderUserInfo
            )
            
            let successfulReminderNotificationAdd = await notificationManager.add(request: reminderRequest)
            if !(successfulNotificationAdd && successfulReminderNotificationAdd) {
                errorDetails = ErrorDetails(name: "Notification error", message: "Failed to add notifications for this habit.")
                logger.error("Failed to add notifications for day: \(day.rawValue).")
                return
            }
            logger.debug("Successfully added notifications for day: \(day.rawValue).")
        }
        
        logger.debug("Successfully added notifications for habit with id: \(habit.id).")
        withAnimation(.spring()) {
            showActionNotification = true
        }
        clearInputFields()
        
        do {
            try habitRef.setData(from: habit)
            logger.debug("Successfully added habit with id: \(habit.id)")
        } catch {
            // Remove the ids that were just added above if setting the firebase habit failed.
            notificationManager.removePendingNotifications(withIdentifiers: habit.allNotificationIDs)
            logger.error("Error failed to add habit. \(error)")
        }
    }
    
    /// Removes the activity from the list.
    /// - parameter activity: The activity to remove
    func removeActivity(_ activity: Activity) {
        logger.debug("Removing activity with id: \(activity.id)")
        guard let index = activities.firstIndex(of: activity) else {
            logger.error("Error. Failed to remov activity with id: \(activity.id). Activity couldn't be found in array of activiteis.")
            return
        }
        activities.remove(at: index)
        logger.debug("Successfully removed activity with id: \(activity.id).")
    }
    
    /// Clears all of the string inputs for the add view.
    private func clearInputFields() {
        habitName = ""
        occurrenceTime = Date()
        occurrenceDays = []
        durationHours = 0
        durationMinutes = 0
        activityInput = ""
        activities = []
        reason = ""
    }
}
