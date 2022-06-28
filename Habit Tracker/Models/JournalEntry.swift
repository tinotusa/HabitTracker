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
        var isCompleted: Bool = false
    }
    /// The id of the entry.
    var id: String
    /// The id of creator.
    var createdBy: String
    /// The id of the habit the entry is associated with.
    var habitID: String
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

extension JournalEntry {
    static var example: JournalEntry {
        JournalEntry(
            id: UUID().uuidString,
            createdBy: UUID().uuidString,
            habitID: UUID().uuidString,
            habitName: "test habit",
            entry: "some test entryy",
            activities: [.init(name: "something", isCompleted: true), .init(name: "another thing", isCompleted: true)],
            rating: 4
        )
    }
}
