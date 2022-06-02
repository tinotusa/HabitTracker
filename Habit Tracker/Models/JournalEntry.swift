//
//  JournalEntry.swift
//  Habit Tracker
//
//  Created by Tino on 30/5/2022.
//

import Foundation

/// Represents a journal entry.
struct JournalEntry: Codable, Identifiable {
    /// A struct to represent the users activity.
    struct Activity: Codable, Identifiable {
        var id = UUID().uuidString
        /// The name of the activity.
        var name: String
        /// A boolean value that represents whether the activity was completed.
        var isCompleted: Bool
    }
    /// The id of the entry.
    var id: String
    /// The name of the habit.
    var habitName: String
    /// The journal entry.
    let entry: String
    /// The acitvities the use has written.
    let activities: [Activity]
    /// The rating of the day.
    let rating: Int
    /// The creating date of the entry.
    var dateCreated = Date()
}
