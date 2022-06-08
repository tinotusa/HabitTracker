//
//  Habit_TrackerTests.swift
//  Habit TrackerTests
//
//  Created by Tino on 16/4/2022.
//

import XCTest
@testable import Habit_Tracker

class Habit_TrackerTests: XCTestCase {
    var viewModel: CalendarViewViewModel!
    
    override func setUpWithError() throws {
        viewModel = CalendarViewViewModel(calendarService: MockCalendarService())
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    /// Tests to see if the init has empty entires.
    func test_init() {
        XCTAssertTrue(viewModel.entriesForSelectedDate.isEmpty)
    }
    
    /// Tests to see if the view model will return no entries.
    func test_getHabitsForMonth_withNoEntries() async {
        await viewModel.getHabitsForMonth(date: Date())
        XCTAssertTrue(viewModel.entriesForSelectedDate.isEmpty)
    }
    
    /// Add an entry and check if it is found in the entries array.
    func test_hasJournalEntry() {
        for _ in 0 ..< 10 {
            let entry = JournalEntry.example // The date created is today (Date()).
            viewModel.entriesForSelectedDate.append(entry)
        }
        XCTAssertTrue(viewModel.hasJournalEntry(for: Date()))
    }
    
    /// Tests to see if hasJournalEntry is false when there are no entries added.
    func test_hasJournalEntry_withoutAddingAnyEntries() {
        XCTAssertFalse(viewModel.hasJournalEntry(for: Date()))
    }
}
