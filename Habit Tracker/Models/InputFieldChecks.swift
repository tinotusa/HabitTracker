//
//  InputFieldChecks.swift
//  Habit Tracker
//
//  Created by Tino on 29/6/2022.
//

import Foundation

/// A type that checks the lengths of textfields
protocol InputFieldChecks {
    func checkNameLength(name: String)
    func checkActivityInputLength(activity: String)
    func checkReasonInputLength(reason: String)
}
