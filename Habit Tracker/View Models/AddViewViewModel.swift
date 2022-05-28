//
//  AddViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 24/5/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

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
    
    /// Adds the habit to the firestore database.
    func addHabit(session: UserSession) {
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
