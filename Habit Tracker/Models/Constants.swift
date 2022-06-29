//
//  Constants.swift
//  Habit Tracker
//
//  Created by Tino on 11/6/2022.
//

import Foundation

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
    
    static private let nameCharLimit = 40
    static private let activityCharLimit = 40
    static private let reasonCharLimit = 200
    static private let journalEntryCharLimit = 200
    
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
    private static func limit(text: String, to maxLength: Int) -> String {
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
        return Self.limit(text: name, to: Self.nameCharLimit)
    }
    
    /// Limits the length of the activity input.
    ///
    /// - parameter activity: The value of the textfield.
    ///
    /// - returns: The activity truncated to a certain limit or the activity unchanged.
    static func checkActivityInputLength(activity: String) -> String {
        return Self.limit(text: activity, to: Self.activityCharLimit)
    }
    
    /// Limits the length of the reason input.
    ///
    /// - parameter reason: The value of the texteditor.
    ///
    /// - returns: The reason truncated to a certain limit or the reason unchanged.
    static func checkReasonInputLength(reason: String) -> String {
        return Self.limit(text: reason, to: Self.reasonCharLimit)
    }
    
    /// Limits the length of the journal entry input.
    ///
    /// - parameter reason: The value of the texteditor.
    ///
    /// - returns: The journal entry truncated to a certain limit or the journal entry unchanged.
    static func checkEntryLength(entry: String) -> String {
        return Self.limit(text: entry, to: Self.journalEntryCharLimit)
    }
}
