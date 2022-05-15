//
//  ErrorDetails.swift
//  Habit Tracker
//
//  Created by Tino on 15/5/2022.
//

import Foundation

struct ErrorDetails: Identifiable {
    let id = UUID().uuidString
    var name: String
    var message: String
}
