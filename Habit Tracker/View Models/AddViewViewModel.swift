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
    
    /// When the habit is usually done.
    @Published var occurrenceDate = Date()
    
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
    
    /// The total duration the habit takes to complete in seconds.
    var totalDurationSeconds: Int {
        durationHours * 60 + durationMinutes * 60
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
    
    /// Adds the habit to the database.
    func addHabit() {
        // TODO: implement
    }
    
    /// Removes the activity from the list.
    func removeActivity(activity: String) {
        guard let index = activities.firstIndex(of: activity) else {
            return
        }
        activities.remove(at: index)
    }

}
