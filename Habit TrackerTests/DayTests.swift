//
//  DayTests.swift
//  Habit TrackerTests
//
//  Created by Tino on 8/6/2022.
//

import XCTest
@testable import Habit_Tracker

class DayTests: XCTestCase {
    var validWeekdayFullNames: [String]!
    var validWeekdayShortNames: [String]!
    
    override func setUp() {
        validWeekdayFullNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        validWeekdayShortNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }
    
    /// Tests that the indicies of the day are correct.
    func test_init() {
        for dayIndex in 0 ..< 7 {
            let day = Day(rawValue: dayIndex)
            XCTAssertEqual(day?.rawValue, dayIndex, "The index of the days do not match")
        }
    }
    
    /// Tests the logic of the days
    func test_isWeekday() {
        for _ in 0 ..< 50 {
            let dayIndex = Int.random(in: 0 ..< 7)
            let day = Day(rawValue: dayIndex)!
            
            if day.rawValue == 0 || day.rawValue == 6 {
                XCTAssertTrue(day.isWeekend)
            } else {
                XCTAssertTrue(day.isWeekday)
            }
        }
    }
    
    /// Tests to see if the fullnames of the weekday are correct.
    func test_fullName() {
        for _ in 0 ..< 30 {
            let randomIndex = Int.random(in: 0 ..< validWeekdayFullNames.count)
            let day = Day(rawValue: randomIndex)!
            XCTAssertEqual(day.fullName, validWeekdayFullNames[randomIndex], "Day doesn't have the correct name")
        }
    }
    
    /// Tests to see if the short names are correct.
    func test_shortName() {
        for _ in 0 ..< 30 {
            let randomIndex = Int.random(in: 0 ..< validWeekdayShortNames.count)
            let day = Day(rawValue: randomIndex)!
            let randomShortName = validWeekdayShortNames[randomIndex]
            XCTAssertEqual(day.shortName, randomShortName, "Day doesn't have the same short name.")
        }
    }
    
    /// Tests to see if the Day has the correct id.
    func test_id() {
        let day = Day.monday
        XCTAssertEqual(day.id, Day.monday, "Day doesn't have the correct id.")
    }
}
