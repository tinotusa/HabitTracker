//
//  Habit.swift
//  Habit Tracker
//
//  Created by Tino on 28/5/2022.
//

import Foundation

struct Activity: Identifiable, Codable, Equatable {
    var id = UUID().uuidString
    var name: String
}

/// A struct representing a habit.
struct Habit: Codable, Identifiable, Equatable {
    /// The id of the habit.
    var id: String
    
    /// The id of creator.
    var createdBy: String
    
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
    var activities: [Activity]
    
    /// The reason for quitting or starting the habit being added.
    var reason: String
    
    /// The local notification id.
    var localNotificationID: String
    
    /// The reminder local notification id.
    var localReminderNotificationID: String
}

extension Habit {
    init(
        id: String,
        createdBy: String,
        isQuittingHabit: Bool,
        isStartingHabit: Bool,
        name: String,
        occurrenceTime: Date,
        occurrenceDays: Set<Day>,
        durationHours: Int,
        durationMinutes: Int,
        activities: [Activity],
        reason: String
    ) {
        self.id = id
        self.createdBy = createdBy
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
        localNotificationID = UUID().uuidString
        localReminderNotificationID = UUID().uuidString
    }
    
//    init(copy habit: Habit) {
//        self.id = habit.id
//        createdAt = habit.createdAt
//        self.isQuittingHabit = habit.isQuittingHabit
//        self.isStartingHabit = habit.isStartingHabit
//        self.name = habit.name
//        self.occurrenceTime = habit.occurrenceTime
//        self.occurrenceDays = habit.occurrenceDays
//        self.durationHours = habit.durationHours
//        self.durationMinutes = habit.durationMinutes
//        self.activities = habit.activities
//        self.reason = habit.reason
//        localNotificationID = habit.localNotificationID
//        localReminderNotificationID = habit.localReminderNotificationID
//    }
    
    static var example: Habit {
        Habit(
            id: UUID().uuidString,
            createdBy: UUID().uuidString,
            isQuittingHabit: true,
            isStartingHabit: false,
            name: "test name",
            occurrenceTime: Date(),
            occurrenceDays: [.monday, .tuesday],
            durationHours: 0,
            durationMinutes: 10,
            activities: [.init(name: "activity 1"), .init(name: "activity 2")],
            reason: "some test reason"
        )
    }
}
