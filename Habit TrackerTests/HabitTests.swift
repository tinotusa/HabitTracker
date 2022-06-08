//
//  HabitTests.swift
//  Habit TrackerTests
//
//  Created by Tino on 8/6/2022.
//

import XCTest
@testable import Habit_Tracker

class HabitTests: XCTestCase {
    /// Tests habit init.
    func test_init() {
        for _ in 0 ..< 30 {
            let id = UUID().uuidString
            let createdBy = UUID().uuidString
            let createdAt = Date()
            let isQuittingHabit = Bool.random()
            let isStartingHabit = !isQuittingHabit
            let name = randomString()
            let occurrenceTime = Date()
            let occurrenceDays = Set<Day>()
            let durationHours = Int.random(in: 0 ..< 24)
            let durationMinutes = Int.random(in: 0 ..< 60)
            let activities = [Activity]()
            let reason = randomString()
            let localNotificationID = UUID().uuidString
            let localReminderNotificationID = UUID().uuidString
            
            let habit = Habit(
                id: id,
                createdBy: createdBy,
                createdAt: createdAt,
                isQuittingHabit: isQuittingHabit,
                isStartingHabit: isStartingHabit,
                name: name,
                occurrenceTime: occurrenceTime,
                occurrenceDays: occurrenceDays,
                durationHours: durationHours,
                durationMinutes: durationMinutes,
                activities: activities,
                reason: reason,
                localNotificationID: localNotificationID,
                localReminderNotificationID: localReminderNotificationID
            )
            
            XCTAssertEqual(habit.id, id)
            XCTAssertEqual(habit.createdBy, createdBy)
            XCTAssertEqual(habit.createdAt, createdAt)
            XCTAssertEqual(habit.isQuittingHabit, isQuittingHabit)
            XCTAssertEqual(habit.isStartingHabit, isStartingHabit)
            XCTAssertEqual(habit.name, name)
            XCTAssertEqual(habit.occurrenceTime, occurrenceTime)
            XCTAssertEqual(habit.occurrenceDays, occurrenceDays)
            XCTAssertEqual(habit.durationHours, durationHours)
            XCTAssertEqual(habit.durationMinutes, durationMinutes)
            XCTAssertEqual(habit.activities, activities)
            XCTAssertEqual(habit.reason, reason)
            XCTAssertEqual(habit.localNotificationID, localNotificationID)
            XCTAssertEqual(habit.localReminderNotificationID, localReminderNotificationID)
        }
    }

}
