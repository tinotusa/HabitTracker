//
//  Constants.swift
//  Habit Tracker
//
//  Created by Tino on 11/6/2022.
//

import Foundation

struct InputFieldCharLimit {
    // activity inputs
    static let activityNameCharLimit = 100
    // habit inputs
    static let habitNameCharLimit = 40
    static let activityCharLimit = 40
    static let reasonCharLimit = 200
    static let journalEntryCharLimit = 200
    
    // sign up inputs
    static let name = 100 // first and last
    static let email = 100
    static let password = 100
}

struct Constants {
    static let cornerRadius =  20.0
    static let buttonCornerRadius = 30.0
    static let shadowOpacity = 0.8
    static let shadowRadius = 5.0
    static let vstackSpacing = 30.0
    static let habitRowVstackSpacing = 15.0
    static let minTextEditorHeight = 100.0
    static let maxTextEditorHeight = 300.0
    static let entryDetailHeight = 600.0
    static let disabledButtonOpacity = 0.5
    static let maxActivitiesPerHabit = 5
    static let maxIDLength = 128
    static let minRating = 1
    static let maxRating = 5
    
    /// Truncates the given input to some max length or returns it unchanged if
    /// the string's length is less than the given max length.
    ///
    ///     limit(text: "Hello, world", to: 5) = "Hello"
    ///     limit(text: "Hello, world", to: 100) = "Hello, world"
    ///
    /// - parameter text: The string to be truncated.
    /// - parameter maxLength: The max length allowed for the string.
    ///
    /// - returns: The truncated text or the text unchanged if it's length was less than the maxLength.
    static func limit(text: String, to maxLength: Int) -> String {
        if text.count > maxLength {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: maxLength)
            return String(text[startIndex ..< endIndex])
        }
        return text
    }
    
    /// limits the length of the name
    ///
    /// - parameter name: The value of the textfield.
    ///
    /// - returns: The name truncated to a certain limit or the name unchanged.
    static func checkNameLength(name: String) -> String {
        return Self.limit(text: name, to: InputFieldCharLimit.habitNameCharLimit)
    }
    
    /// Limits the length of the activity input.
    ///
    /// - parameter activity: The value of the textfield.
    ///
    /// - returns: The activity truncated to a certain limit or the activity unchanged.
    static func checkActivityInputLength(activity: String) -> String {
        return Self.limit(text: activity, to: InputFieldCharLimit.activityCharLimit)
    }
    
    /// Limits the length of the reason input.
    ///
    /// - parameter reason: The value of the texteditor.
    ///
    /// - returns: The reason truncated to a certain limit or the reason unchanged.
    static func checkReasonInputLength(reason: String) -> String {
        return Self.limit(text: reason, to: InputFieldCharLimit.reasonCharLimit)
    }
    
    /// Limits the length of the journal entry input.
    ///
    /// - parameter reason: The value of the texteditor.
    ///
    /// - returns: The journal entry truncated to a certain limit or the journal entry unchanged.
    static func checkEntryLength(entry: String) -> String {
        return Self.limit(text: entry, to: InputFieldCharLimit.journalEntryCharLimit)
    }
}
