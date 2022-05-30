//
//  Habit.swift
//  Habit Tracker
//
//  Created by Tino on 28/5/2022.
//

import Foundation

/// A struct representing a habit.
struct Habit: Codable, Identifiable {
    /// The id of the habit.
    var id: String
    /// The date that the habit was created.
    var createdAt: Date
    /// A boolean value indicating whether a habit is being quit (stopped).
    var isQuittingHabit: Bool
    
    /// A boolean value indicating whether a habit is being started (created).
    var isStartingHabit: Bool
    
    /// The name of the habit being quit or started.
    var name: String
    
    /// What time the habit is usually done.
    var occurrenceTime: Date
    
    /// What days the habit is usually done.
    var occurrenceDays: Set<Day>
    
    /// The hours it takes to complete the habit.
    var durationHours: Int
    
    /// The mintues it takes to complete the habit.
    var durationMinutes: Int
    
    /// A list of the activities the user has added.
    var activities: [String]
    
    /// The reason for quitting or starting the habit being added.
    var reason: String
}

extension Habit {
    init(
        id: String,
        isQuittingHabit: Bool,
        isStartingHabit: Bool,
        name: String,
        occurrenceTime: Date,
        occurrenceDays: Set<Day>,
        durationHours: Int,
        durationMinutes: Int,
        activities: [String],
        reason: String
    ) {
        self.id = id
        createdAt = Date()
        self.isQuittingHabit = isQuittingHabit
        self.isStartingHabit = isStartingHabit
        self.name = name
        self.occurrenceTime = occurrenceTime
        self.occurrenceDays = occurrenceDays
        self.durationHours = durationHours
        self.durationMinutes = durationMinutes
        self.activities = activities
        self.reason = reason
    }
    
    static var example: Habit {
        Habit(
            id: UUID().uuidString,
            isQuittingHabit: true,
            isStartingHabit: false,
            name: "test name",
            occurrenceTime: Date(),
            occurrenceDays: [.monday, .tuesday],
            durationHours: 0,
            durationMinutes: 10,
            activities: ["activity 1", "activity 2"],
            reason: "some test reason"
        )
    }
}
