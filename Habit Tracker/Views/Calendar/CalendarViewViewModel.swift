//
//  CalendarViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 31/5/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

@MainActor
final class CalendarViewViewModel: ObservableObject {
    @Published var entriesForSelectedDate = [JournalEntry]()
    private var userSession: UserSession!
    private lazy var firestore = Firestore.firestore()
    private lazy var functions = Functions.functions(region: "australia-southeast1")
    private var maxQueryLimit = 50
}

extension CalendarViewViewModel {
    func hasJournalEntry(for date: Date) -> Bool {
        for entry in entriesForSelectedDate {
            if entry.dateCreated.isEqual(to: date) {
                return true
            }
        }
        return false
    }
    
    func getHabitsForMonth(date: Date) async {
        precondition(userSession.isSignedIn, "User is not signed in.")
        
        // TODO: Move to date as extension
        let calendar = Calendar.current
        let dateComps = calendar.dateComponents([.month, .year], from: date)
        guard let monthStart = calendar.date(from: dateComps) else { return }
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return }
        var arr = [Int](range)
        arr.insert(0, at: 0) // TODO: figure out if this is the only way to do this (if range is 1..<31 the first date is skipped)
        let dates = arr.compactMap { day in
            calendar.date(byAdding: .day, value: day, to: monthStart)
        }
        
        let startDate = dates.first!
        let endDate = dates.last!
        
        var temp = [JournalEntry]()
        do {
            let result = try await functions.httpsCallable("getAllHabitIDs").call()
            guard let dict = result.data as? [String: [String]] else { return }
            guard let collectionIDS = dict["collections"] else { return }
            for collectionID in collectionIDS {
                let query = firestore
                    .collectionGroup(collectionID)
                    .whereField("dateCreated", isGreaterThanOrEqualTo: startDate)
                    .whereField("dateCreated", isLessThanOrEqualTo: endDate)
                    .limit(to: maxQueryLimit)
                
                let snapshot = try await query.getDocuments()
                for document in snapshot.documents {
                    let journalEntry = try document.data(as: JournalEntry.self)
                    temp.append(journalEntry)
                }
            }
            entriesForSelectedDate = temp
        } catch {
            print("\(error)")
        }
    }
    
    func setUp(userSession: UserSession, date: Date) {
        self.userSession = userSession
//        self.date = date
    }
}

private extension CalendarViewViewModel {
    
}
