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
import SwiftUI

struct PermissionDetails {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
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
    
    let reasonPrompt = LocalizedStringKey("Reason")
    let activityInputPrompt = LocalizedStringKey("Activity")
    let habitNamePrompt = LocalizedStringKey("Name")
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
        
        if !(isQuittingHabit ||  isStartingHabit) { return false }
        if habitName.isEmpty { return false }
        if occurrenceDays.isEmpty { return false }
        if (durationHours == 0 && durationMinutes == 0) { return false }
        if isQuittingHabit && activities.isEmpty { return false }
        if reason.isEmpty { return false }
        
        return true
    }
}

// MARK: - InputFieldChecks conformance
extension AddViewViewModel: InputFieldChecks {
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
extension AddViewViewModel {
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
        withAnimation(.spring()) {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }
        precondition(session.currentUser != nil, "User is not logged in")
        assert(allFieldsFilled, "All fields not filled in")
        guard let user = session.currentUser else {
            preconditionFailure("User is not logged in.")
        }

        let habitRef = firestore
            .collection("habits")
            .document(user.uid)
            .collection("habits")
            .document()

        let habit = Habit(
            id: habitRef.documentID,
            createdBy: user.uid,
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
            let notificationManager = NotificationManager()
            
            await notificationManager.requestAuthorization(options: [.alert, .badge, .sound])
            
            if await !notificationManager.hasPermissions() {
                permissionsDetails = PermissionDetails(
                    title: "Allow reminders for habits",
                    message: "Please allow the notifications for this app, so that it can remind you when you need to complete a certain habit"
                )
            }
            
            let title = habit.isQuittingHabit ? "Quitting \(habit.name)" : "Starting \(habit.name)"
            let body = habit.isQuittingHabit ?
            "You are quitting \(habit.name), try to do this instead: \(habit.activities.randomElement()!.name)" :
            "You are starting \(habit.name). Make sure to do it to help the habit stick"
            
            let reminderTitle = "Write journal entry"
            let reminderBody = "You should have finished \(habit.name), how do you feel?"
            let reminderUserInfo = [
                "USER_ID": user.uid,
                "HABIT_ID": habit.id
            ]
            let reminderCategoryIdentifier = "JOURNAL_ENTRY"
            
            for day in habit.occurrenceDays {
                var dateComponents = DateComponents()
                dateComponents.weekday = day.rawValue + 1
                let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: habit.occurrenceTime)
                dateComponents.hour = timeComponents.hour ?? 0
                dateComponents.minute = (timeComponents.minute ?? 0)
                
                let request = NotificationManager.request(
                    identifier: habit.localNotificationID,
                    title: title,
                    body: body,
                    dateComponents: dateComponents,
                    repeats: true
                )
                
                let successfulNotificationAdd = await NotificationManager.add(request: request)
    
                var reminderDateComponents = DateComponents()
                reminderDateComponents.weekday = day.rawValue + 1
                reminderDateComponents.hour = timeComponents.hour ?? 0 + habit.durationHours
                reminderDateComponents.minute = (timeComponents.minute ?? 0) + habit.durationMinutes
                
                let reminderRequest = NotificationManager.request(
                    identifier: habit.localReminderNotificationID,
                    title: reminderTitle,
                    body: reminderBody,
                    dateComponents: reminderDateComponents,
                    repeats: true,
                    categoryIdentifier: reminderCategoryIdentifier,
                    userInfo: reminderUserInfo
                )

                let successfulReminderNotificationAdd = await NotificationManager.add(request: reminderRequest)
                if !(successfulNotificationAdd && successfulReminderNotificationAdd) {
                    errorDetails = ErrorDetails(name: "Notification error", message: "Failed to add notifications for this habit.")
                }
            }
            withAnimation(.spring()) {
                showActionNotification = true
            }
            clearInputFields()
        } catch {
            print("Error in \(#function): \(error)")
        }
    }
    
    /// Removes the activity from the list.
    func removeActivity(activity: Activity) {
        guard let index = activities.firstIndex(of: activity) else {
            preconditionFailure("Activity: \(activity) isn't in the array of activities.")
        }
        activities.remove(at: index)
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
