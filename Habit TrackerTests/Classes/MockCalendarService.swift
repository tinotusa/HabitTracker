//
//  MockCalendarService.swift
//  Habit TrackerTests
//
//  Created by Tino on 8/6/2022.
//

import Foundation
@testable import Habit_Tracker

final class MockCalendarService: CalendarServiceProtocol {
    private var entries = [JournalEntry]()
    
    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
    }
    
    func getHabitsForMonth(date: Date) async -> [JournalEntry] {
        var results = [JournalEntry]()
        for entry in entries {
            if entry.dateCreated.isEqual(to: date) {
                results.append(entry)
            }
        }
        return results
    }
    
    func hasJournalEntry(for date: Date) -> Bool {
        for entry in entries {
            if entry.dateCreated.isEqual(to: date) {
                return true
            }
        }
        return false
    }
}
