//
//  CalendarService.swift
//  Habit Tracker
//
//  Created by Tino on 8/6/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions
import FirebaseAuth

protocol CalendarServiceProtocol {
    func getHabitsForMonth(date: Date) async -> [JournalEntry]
}

final class CalendarService: CalendarServiceProtocol {
    private lazy var firestore = Firestore.firestore()
    private lazy var functions = Functions.functions(region: "australia-southeast1")
    private lazy var auth = Auth.auth()
    private let maxQueryLimit = 50
    
    func getHabitsForMonth(date: Date) async -> [JournalEntry] {
        guard let user = auth.currentUser else {
            preconditionFailure("User is not logged in.")
        }
        // TODO: Move to date as extension
        let calendar = Calendar.current
        let dateComps = calendar.dateComponents([.month, .year], from: date)
        guard let monthStart = calendar.date(from: dateComps) else { return [] }
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return [] }
        var arr = [Int](range)
        arr.insert(0, at: 0) // TODO: figure out if this is the only way to do this (if range is 1..<31 the first date is skipped)
        let dates = arr.compactMap { day in
            calendar.date(byAdding: .day, value: day, to: monthStart)
        }
        
        let startDate = dates.first!
        let endDate = dates.last!
        
        var entries = [JournalEntry]()
        do {
            let query = firestore
                .collectionGroup("journalEntries")
                .whereField("createdBy", isEqualTo: user.uid)
                .whereField("dateCreated", isGreaterThanOrEqualTo: startDate)
                .whereField("dateCreated", isLessThanOrEqualTo: endDate)
                .limit(to: maxQueryLimit)
            let snapshot = try await query.getDocuments()
            for document in snapshot.documents {
                let journalEntry = try document.data(as: JournalEntry.self)
                entries.append(journalEntry)
            }
            return entries
        } catch {
            print("\(error)")
        }
        return []
    }
}
