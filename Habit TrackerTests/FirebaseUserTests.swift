//
//  FirebaseUserTests.swift
//  Habit TrackerTests
//
//  Created by Tino on 8/6/2022.
//

import XCTest
@testable import Habit_Tracker

func randomString(length: Int = 10) -> String {
    var word = ""
    let letters = Array("abcdefghijklmnopqrstuvwxyz")
    for _ in 0 ..< length {
        let randomCharacter = letters.randomElement()!
        word.append(randomCharacter)
    }
    return word
}

class FirebaseUserTests: XCTestCase {
    /// Tests that the init sets the fields correctly.
    func test_init() {
        for _ in 0 ..< 20 {
            let id = UUID().uuidString
            let firstName = randomString()
            let lastName = randomString()
            let email = "\(randomString())@\(randomString()).com"
            let birthday = Date()
            
            let user = FirebaseUser(
                id: id,
                firstName: firstName,
                lastName: lastName,
                email: email,
                birthday: birthday
            )
            
            XCTAssertEqual(user.id, id)
            XCTAssertEqual(user.firstName, firstName)
            XCTAssertEqual(user.lastName, lastName)
            XCTAssertEqual(user.email, email)
            XCTAssertEqual(user.birthday, birthday)
        }
    }
}
