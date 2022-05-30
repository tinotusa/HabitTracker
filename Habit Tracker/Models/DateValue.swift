//
//  DateValue.swift
//  Habit Tracker
//
//  Created by Tino on 30/5/2022.
//

import Foundation

struct DateValue: Identifiable {
    let id = UUID().uuidString
    let day: Int
    let date: Date
}
