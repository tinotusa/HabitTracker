//
//  EditHabitViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 4/6/2022.
//

import FirebaseFirestore
import FirebaseFunctions
import SwiftUI
import os

/// The  view model for EditHabitView.
final class EditHabitViewViewModel: ObservableObject {
    /// A boolean value indicating whether the edit operation had an error.
    @Published var didError = false
    
    /// The information about the error.
    @Published private(set) var errorDetails: ErrorDetails? {
        didSet {
            if errorDetails != nil {
                DispatchQueue.main.async {
                    self.didError = true
                }
            }
        }
    }
    
    /// A boolean value indicating whether the save operation was successful or not.
    @Published private(set) var hasSavedSuccessfully = false
    
    /// The input for the activity being added.
    @Published var activityInput = ""
    
    /// The habit being edited.
    @Published var habit: Habit
    /// The current user session.
    var userSession: UserSession!
    /// The prompt for the activity input text field.
    let activityInputPrompt: LocalizedStringKey = "Name ..."
    
    @Published var isLoading = false
    @Published var showActionNotification = false
    
    private lazy var firestore = Firestore.firestore()
    private var logger = Logger(subsystem: "com.tinotusa.HabitTracker", category: "EditHabitViewViewModel")
    
    init(habit: Habit) {
        self.habit = habit
    }
}

// MARK: - Computed Properties
extension EditHabitViewViewModel {
    var name: String {
        get {
            habit.name
        }
        set(name) {
            if name.isEmpty { return }
            habit.name = name
        }
    }
    
    var habitState: HabitState {
        get { habit.habitState }
        set { habit.habitState = newValue }
    }
    
    var activities: [Activity] {
        get { habit.activities }
        set(activities) {
            habit.activities = activities
        }
    }
    
    var occurrenceTime: Date {
        get { habit.occurrenceTime }
        set { habit.occurrenceTime = newValue }
    }
    
    var occurrenceDays: Set<Day> {
        get { habit.occurrenceDays }
        set { habit.occurrenceDays = newValue }
    }
    
    var durationHours: Int {
        get { habit.durationHours }
        set { habit.durationHours = newValue }
    }
    
    var durationMinutes: Int {
        get { habit.durationMinutes }
        set { habit.durationMinutes = newValue }
    }
    
    var reason: String {
        get { habit.reason }
        set { habit.reason = newValue }
    }
    
    var reasonTextPrompt: LocalizedStringKey {
        habitState == .quitting ? "Reason for quitting habit" : "Reason for starting habit"
    }
}

// MARK: - Functions
extension EditHabitViewViewModel {
    /// Saves the edited habit.
    /// - parameter notificationManager: The manager for the apps notifications.
    /// - returns: `True` if the save was successful, `False` if something went wrong.
    @MainActor
    @discardableResult
    func saveHabit(notificationManager: NotificationManager) async -> Bool {
        logger.debug("Starting to save habit.")
        withAnimation(.spring()) {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }
        guard let user = userSession.currentUser else {
            logger.error("Error failed to save habit. User is not logged in.")
            return false
        }
        
        let query = firestore
            .collectionGroup("habits")
            .whereField("createdBy", isEqualTo: user.uid)
            .whereField("id", isEqualTo: habit.id)
            .limit(to: 1)
        
        do {
            // remove old ids
            notificationManager.removePendingNotifications(withIdentifiers: habit.allNotificationIDs)
            habit.localNotificationIDs = []
            habit.localReminderNotificationIDs = []
            
            let title = habit.habitState == .quitting ? "Quitting habit \(habit.name)." : "Starting habit: \(habit.name)."
            let body = habit.habitState == .quitting ? "Around this time you would do habit: \(habit.name)." : "Time to start habit: \(habit.name)."
            let reminderTitle = "Write journal entry for habit: \(habit.name)."
            let reminderBody = habit.habitState == .quitting ? "What did you do instead of habit: \(habit.name)" : "You should have finished habit: \(habit.name)."
            
            for day in habit.occurrenceDays {
                var dateComponents = DateComponents()
                let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: habit.occurrenceTime)
                guard let hour = timeComponents.hour else {
                    logger.error("Error failed to get time componenet from habit occurrenceTime.")
                    return false
                }
                guard let minute = timeComponents.minute else {
                    logger.error("Error failed to get time componenet from habit occurrenceTime.")
                    return false
                }
                
                dateComponents.weekday = day.rawValue + 1
                dateComponents.hour = hour
                dateComponents.minute = minute
                let id = UUID().uuidString
                habit.localNotificationIDs.append(id)
                let request = notificationManager.request(
                    identifier: id,
                    title: title,
                    body: body,
                    dateComponents: dateComponents,
                    repeats: true
                )
                dateComponents.hour = hour + habit.durationHours
                dateComponents.minute = minute + habit.durationMinutes
                let reminderID = UUID().uuidString
                habit.localReminderNotificationIDs.append(reminderID)
                let reminderRequest = notificationManager.request(
                    identifier: reminderID,
                    title: reminderTitle,
                    body: reminderBody,
                    dateComponents: dateComponents,
                    repeats: true,
                    categoryIdentifier: NotificationActionIdentifiers.journalEntry,
                    userInfo: [
                        "USER_ID": user.uid,
                        "HABIT_ID": habit.id
                    ]
                )
                
                let mainNotification = await notificationManager.add(request: request)
                let reminderNotification = await notificationManager.add(request: reminderRequest)
                if !(mainNotification && reminderNotification) {
                    errorDetails = ErrorDetails(name: "Notification Errror.", message: "Failed to set the notification for this habit.")
                }
                
                let snapshot = try await query.getDocuments()
                if snapshot.documents.isEmpty {
                    logger.error("Error. No habit document with id: \(self.habit.id).")
                    return false
                }
                let docRef = snapshot.documents.first!.reference
                try docRef.setData(from: habit, merge: true)
                
                hasSavedSuccessfully = true
                logger.debug("Successfully saved habit with id: \(self.habit.id)")
                withAnimation(.spring()) {
                    showActionNotification = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorDetails = ErrorDetails(
                    name: "Save Error",
                    message: "Failed to save changes. Please try again."
                )
            }
            logger.error("Error failed to save habit. \(error)")
            return false
        }
        return true
    }
    
    /// Adds the activity to the habits activity list.
    func addActivity() {
        if activityInput.isEmpty || activities.count >= Constants.maxActivitiesPerHabit { return }
        let activity = Activity(name: activityInput)
        habit.activities.append(activity)
        activityInput = ""
    }
    
    /// Removes an activity from the activities array.
    ///
    /// - parameter activity: The activity to be removed.
    func removeActivity(_ activity: Activity) {
        guard let index = habit.activities.firstIndex(where: { item in
            item == activity
        }) else {
            preconditionFailure("No such activity: \(activity)")
        }
        habit.activities.remove(at: index)
    }
}

// MARK: - InputFieldChecks conformance.
extension EditHabitViewViewModel: InputFieldChecks {
    func checkNameLength(name: String) {
        self.name = Constants.checkNameLength(name: name)
    }
    
    func checkActivityInputLength(activity: String) {
        activityInput = Constants.checkActivityInputLength(activity: activity)
    }
    
    func checkReasonInputLength(reason: String) {
        self.reason = Constants.checkReasonInputLength(reason: reason)
    }
}
