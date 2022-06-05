//
//  EditHabitViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 4/6/2022.
//

import FirebaseFirestore
import FirebaseFunctions

/// ViewModel for EditHabitView
@MainActor
final class EditHabitViewViewModel: ObservableObject {
    /// A boolean value indicating whether the edit operation had an error.
    @Published var didError = false
    
    /// The information about the error.
    @Published var errorDetails: ErrorDetails? {
        didSet {
            if errorDetails != nil {
                didError = true
            }
        }
    }
    
    /// A boolean value indicating whether the save operation was successful or not.
    @Published var hasSavedSuccessfully = false
    private lazy var firestore = Firestore.firestore()
    
    /// Saves the edited habit.
    @discardableResult
    func saveHabit(_ habit: Habit, userSession: UserSession) async -> Bool {
        precondition(userSession.isSignedIn, "User is not signed in.")
        guard let user = userSession.currentUser else { return false }
        
        let query = firestore.collectionGroup("habits")
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
            errorDetails = ErrorDetails(
                name: "Save Error",
                message: "Failed to save changes. Please try again."
            )
            print("Error in \(#function)\n\(error)")
            return false
        }
        return true
    }
}
