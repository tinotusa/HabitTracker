//
//  Date+isEqual.swift
//  Habit Tracker
//
//  Created by Tino on 31/5/2022.
//

import Foundation

extension Date {
    func isEqual(to other: Date) -> Bool {
        let order = Calendar.current.compare(self, to: other, toGranularity: .day)
        switch order {
        case .orderedSame: return true
        default: return false
        }
    }
}
