//
//  InputFieldChecks.swift
//  Habit Tracker
//
//  Created by Tino on 29/6/2022.
//

import Foundation

/// A type that checks the lengths of textfields
protocol InputFieldChecks {
    /// Limits the length of the name.
    ///
    /// - parameter name: The value of the textfield.
    func checkNameLength(name: String)
    
    /// Limits the length of the activity input.
    ///
    /// - parameter activity: The value of the textfield.
    func checkActivityInputLength(activity: String)
    
    /// Limits the length of the reason input.
    ///
    /// - parameter reason: The value of the texteditor.
    func checkReasonInputLength(reason: String)
}
