//
//  FirebaseUser.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseUser: Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var birthday: Date
    @ServerTimestamp var dateCreated = Date()
    
    static var ExampleUser: FirebaseUser {
        FirebaseUser(
            id: UUID().uuidString,
            firstName: "Test name",
            lastName: "test last",
            email: "test@test.com",
            birthday: Date()
        )
    }
}
