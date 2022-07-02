//
//  JournalEntry.swift
//  Habit Tracker
//
//  Created by Tino on 30/5/2022.
//

import Foundation

/// Represents a journal entry.
struct JournalEntry: Codable, Identifiable {
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
    
    init(
        id: String,
        createdBy: String,
        habitID: String,
        habitName: String,
        entry: String,
        activities: [Activity],
        rating: Int
    ) {
        self.id = id
        self.createdBy = createdBy
        self.habitID = habitID
        self.habitName = habitName
        self.entry = entry
        self.activities = activities
        self.rating = rating
        self.dateCreated = Date()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        guard !id.isEmpty && id.count <= Constants.maxIDLength else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Invalid id.")
        }
        
        createdBy = try container.decode(String.self, forKey: .createdBy)
        guard !createdBy.isEmpty && createdBy.count <= Constants.maxIDLength else {
            throw DecodingError.dataCorruptedError(forKey: .createdBy, in: container, debugDescription: "Invalid createBy id.")
        }
        
        habitID = try container.decode(String.self, forKey: .habitID)
        guard !habitID.isEmpty && habitID.count <= Constants.maxIDLength else {
            throw DecodingError.dataCorruptedError(forKey: .habitID, in: container, debugDescription: "Invalid habit id.")
        }
        
        habitName = try container.decode(String.self, forKey: .habitName)
        guard !habitName.isEmpty && habitName.count <= InputFieldCharLimit.habitNameCharLimit else {
            throw DecodingError.dataCorruptedError(forKey: .habitName, in: container, debugDescription: "Invalid habit name.")
        }
        
        entry = try container.decode(String.self, forKey: .entry)
        guard !entry.isEmpty && entry.count <= InputFieldCharLimit.journalEntryCharLimit else {
            throw DecodingError.dataCorruptedError(forKey: .entry, in: container, debugDescription: "Invalid journal entry.")
        }
        
        activities = try container.decode([Activity].self, forKey: .activities)
        guard activities.count <= Constants.maxActivitiesPerHabit else {
            throw DecodingError.dataCorruptedError(forKey: .activities, in: container, debugDescription: "Invalid activities count.")
        }
        
        rating = try container.decode(Int.self, forKey: .rating)
        guard rating >= Constants.minRating && rating <= Constants.maxRating else {
            throw DecodingError.dataCorruptedError(forKey: .rating, in: container, debugDescription: "Invalid rating.")
        }
        
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
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
