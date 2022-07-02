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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        guard !id.isEmpty && id.count <= Constants.maxIDLength else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "invalid id.")
        }
        createdBy = try container.decode(String.self, forKey: .createdBy)
        guard !createdBy.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .createdBy, in: container, debugDescription: "createdBy id cannot be empty.")
        }
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isQuittingHabit = try container.decode(Bool.self, forKey: .isQuittingHabit)
        isStartingHabit = try container.decode(Bool.self, forKey: .isStartingHabit)
        guard !(isQuittingHabit && isStartingHabit) else {
            throw DecodingError.dataCorruptedError(forKey: .isQuittingHabit, in: container, debugDescription: "Habit cannot have isQuitting and isStarting both set to true.")
        }
        guard !(isQuittingHabit == false && isStartingHabit == false) else {
            throw DecodingError.dataCorruptedError(forKey: .isQuittingHabit, in: container, debugDescription: "Habit cannot have isQuitting and isStarting both set to false.")
        }
        name = try container.decode(String.self, forKey: .name)
        guard !name.isEmpty && name.count <= InputFieldCharLimit.name else {
            throw DecodingError.dataCorruptedError(
                forKey: .name,
                in: container,
                debugDescription: "Invalid length of the habit name. Min(1) max(\(InputFieldCharLimit.name))"
            )
        }
        occurrenceTime = try container.decode(Date.self, forKey: .occurrenceTime)
        occurrenceDays = try container.decode(Set<Day>.self, forKey: .occurrenceDays)
        guard !occurrenceDays.isEmpty else {
            throw DecodingError.dataCorruptedError(
                forKey: .occurrenceDays,
                in: container,
                debugDescription: "Habit has no occurrence days."
            )
        }
        durationHours = try container.decode(Int.self, forKey: .durationHours)
        guard durationHours >= 0 && durationHours <= 24 else {
            throw DecodingError.dataCorruptedError(
                forKey: .durationHours,
                in: container,
                debugDescription: "Invalid duration hour(s) must be >= 0 and <= 24."
            )
        }
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        guard durationMinutes >= 0 && durationHours <= 60 else {
            throw DecodingError.dataCorruptedError(
                forKey: .durationMinutes,
                in: container,
                debugDescription: "Invalid duration minute(s) must be >= 0 && <= 60."
            )
        }
        activities = try container.decode([Activity].self, forKey: .activities)
        guard activities.count <= Constants.maxActivitiesPerHabit else {
            throw DecodingError.dataCorruptedError(forKey: .activities, in: container, debugDescription: "Invalid activities count.")
        }
        reason = try container.decode(String.self, forKey: .reason)
        guard !reason.isEmpty && reason.count <= InputFieldCharLimit.reasonCharLimit else {
            throw DecodingError.dataCorruptedError(
                forKey: .reason,
                in: container,
                debugDescription: "Invalid reason length: Min(1) max:(\(InputFieldCharLimit.reasonCharLimit))"
            )
        }
        localNotificationID = try container.decode(String.self, forKey: .localNotificationID)
        guard !localNotificationID.isEmpty && localNotificationID.count <= Constants.maxIDLength else {
            throw DecodingError.dataCorruptedError(
                forKey: .localNotificationID,
                in: container,
                debugDescription: "No local notification id or invalid id."
            )
        }
        localReminderNotificationID = try container.decode(String.self, forKey: .localReminderNotificationID)
        guard !localNotificationID.isEmpty && localReminderNotificationID.count <= Constants.maxIDLength else {
            throw DecodingError.dataCorruptedError(
                forKey: .localReminderNotificationID,
                in: container,
                debugDescription: "No local reminder notificatoin id or invalid id."
            )
        }
    }
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
