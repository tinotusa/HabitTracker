//
//  Day.swift
//  Habit Tracker
//
//  Created by Tino on 24/5/2022.
//

import Foundation

/// The days of the week.
enum Day: Int, CaseIterable, Codable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
}

// MARK: Computed variables
extension Day {
    /// The full name of the day.
    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    /// The short version of the day name.
    var shortName: String {
        let fullName = fullName
        let startIndex = fullName.startIndex
        let endIndex = fullName.index(startIndex, offsetBy: 3)
        return String(fullName.capitalized[startIndex..<endIndex])
    }
    
    // The first letter of the day's name.
    var firstLetter: String {
        String(self.fullName.first ?? "x")
    }
    
    /// Returns true if the day is a weekend.
    var isWeekend: Bool {
        self == .sunday || self == .saturday
    }
    
    /// Returns true if the day is a week day.
    var isWeekday: Bool {
        self == .monday || self == .tuesday || self == .wednesday || self == .thursday || self == .friday
    }
    
    /// Returns the weekend days.
    static var weekends: Set<Day> {
        var days = Set<Day>()
        days.insert(.sunday)
        days.insert(.saturday)
        return days
    }
    
    static var weekdays: Set<Day> {
        var days: Set<Day> = []
        
        var allDays = Self.allCases
        allDays.removeFirst()
        allDays.removeLast()
        allDays.forEach { day in
            days.insert(day)
        }
        
        return days
    }
}

// MARK: Comparable conformance
extension Day: Comparable {
    /**
        Returns true if one day is less than the other.
        Days are numbered from 0 to 6 (sunday being 0).
     */
    static func < (lhs: Day, rhs: Day) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: Identifiable conformance
extension Day: Identifiable {
    /// The id of the case.
    var id: Self { self }
}
