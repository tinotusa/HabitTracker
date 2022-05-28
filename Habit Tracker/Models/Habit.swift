//
//  Habit.swift
//  Habit Tracker
//
//  Created by Tino on 28/5/2022.
//

import Foundation

/// A struct representing a habit.
struct Habit: Codable {
    /// A boolean value indicating whether a habit is being quit (stopped).
    var isQuittingHabit: Bool
    
    /// A boolean value indicating whether a habit is being started (created).
    var isStartingHabit: Bool
    
    /// The name of the habit being quit or started.
    var habitName: String
    
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
