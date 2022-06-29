//
//  EditHabitViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 4/6/2022.
//

import FirebaseFirestore
import FirebaseFunctions
import SwiftUI

/// ViewModel for EditHabitView
@MainActor
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
    let activityInputPrompt = "Name..."
    
    private lazy var firestore = Firestore.firestore()
    
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
    
    var isQuitting: Bool {
        get { habit.isQuittingHabit }
        set { habit.isQuittingHabit = newValue }
    }
    
    var isStarting: Bool {
        get { habit.isStartingHabit }
        set { habit.isStartingHabit = newValue }
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
        isQuitting ? "Reason for quitting habit" : "Reason for starting habit"
    }
}

// MARK: - Functions
extension EditHabitViewViewModel {
    /// Saves the edited habit.
    ///
    /// - returns: `True` if the save was successful, `False` if something went wrong.
    @discardableResult
    func saveHabit() async -> Bool {
        guard let user = userSession.currentUser else {
            preconditionFailure("User is not logged in.")
        }
        
        let query = firestore
            .collectionGroup("habits")
            .whereField("createdBy", isEqualTo: user.uid)
            .whereField("id", isEqualTo: habit.id)
            .limit(to: 1)
        
        do {
            let snapshot = try await query.getDocuments()
            if snapshot.documents.isEmpty {
                preconditionFailure("No habit document with id: \(habit.id).")
            }
            let docRef = snapshot.documents.first!.reference
            try docRef.setData(from: habit, merge: true)
            
            let title = habit.isQuittingHabit ? "Quitting habit \(habit.name)." : "Starting habit: \(habit.name)."
            let body = habit.isQuittingHabit ? "Around this time you would do habit: \(habit.name)." : "Time to start habit: \(habit.name)."
            let reminderTitle = "Write journal entry for habit: \(habit.name)."
            let reminderBody = habit.isQuittingHabit ? "What did you do instead of habit: \(habit.name)" : "You should have finished habit: \(habit.name)."
            
            for day in habit.occurrenceDays {
                var dateComponents = DateComponents()
                let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: habit.occurrenceTime)
                guard let hour = timeComponents.hour else {
                    preconditionFailure("Failed to get time componenet from habit occurrenceTime.")
                }
                guard let minute = timeComponents.minute else {
                    preconditionFailure("Failed to get time componenet from habit occurrenceTime.")
                }
                
                dateComponents.weekday = day.rawValue + 1
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                let request = NotificationManager.request(
                    identifier: habit.localNotificationID,
                    title: title,
                    body: body,
                    dateComponents: dateComponents,
                    repeats: true
                )
                dateComponents.hour = hour + habit.durationHours
                dateComponents.minute = minute + habit.durationMinutes
                
                let reminderRequest = NotificationManager.request(
                    identifier: habit.localReminderNotificationID,
                    title: reminderTitle,
                    body: reminderBody,
                    dateComponents: dateComponents,
                    repeats: true,
                    categoryIdentifier: "JOURNAL_ENTRY",
                    userInfo: [
                        "USER_ID": user.uid,
                        "HABIT_ID": habit.id
                    ]
                )
                
                let mainNotification = await NotificationManager.add(request: request)
                let reminderNotification = await NotificationManager.add(request: reminderRequest)
                if !(mainNotification && reminderNotification) {
                    errorDetails = ErrorDetails(name: "Notification Errror.", message: "Failed to set the notification for this habit.")
                }
                hasSavedSuccessfully = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorDetails = ErrorDetails(
                    name: "Save Error",
                    message: "Failed to save changes. Please try again."
                )
            }
            print("Error in \(#function)\n\(error)")
            return false
        }
        return true
    }
    
    /// Adds the activity to the habits activity list.
    func addActivity() {
        if activityInput.isEmpty { return }
        let activity = Activity(name: activityInput)
        habit.activities.append(activity)
        activityInput = ""
        print(habit.activities)
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
