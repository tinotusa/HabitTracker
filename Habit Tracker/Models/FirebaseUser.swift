//
//  FirebaseUser.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import Foundation

struct FirebaseUser: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var birthday: Date
    var dateCreated = Date()
    
    static var ExampleUser: FirebaseUser {
        FirebaseUser(firstName: "Test name", lastName: "test last", email: "test@test.com", birthday: Date())
    }
}