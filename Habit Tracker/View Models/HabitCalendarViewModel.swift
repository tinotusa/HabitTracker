//
//  HabitCalendarViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 30/5/2022.
//

import Foundation
import FirebaseFirestore

@MainActor
final class HabitCalendarViewModel: ObservableObject {
    @Published var journalEntries = [JournalEntry]()
    @Published var entriesForSelectedDate = [JournalEntry]()
    var habit: Habit!
    var userSession: UserSession!
    
    private lazy var firestore = Firestore.firestore()
    private let maxQueryLimit = 50
}

extension HabitCalendarViewModel {
    /// Sets up the view model.
    /// - parameter usersession: The current session the user is using.
    /// - parameter habit: The current habit being viewed.
    func setUp(userSession: UserSession, habit: Habit) {
        precondition(userSession.isSignedIn, "User is not logged in")

        self.userSession = userSession
        self.habit = habit
    }
    
    /// Returns the entries for the given date.
    ///  - parameter date: The date to get the journal entries from.
    func getJournalEntries(for date: Date) async {
        precondition(userSession.isSignedIn, "User is not logged in")
        guard let user = userSession.currentUser else { return }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        let startDate = calendar.date(from: components)!
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let query = firestore
            .collection("journalEntries")
            .document(user.uid)
            .collection(habit.id)
            .whereField("dateCreated", isGreaterThanOrEqualTo: startDate)
            .whereField("dateCreated", isLessThanOrEqualTo: endDate)
            .limit(to: maxQueryLimit)

        do {
            let snapshot = try await query.getDocuments()
            var temp = [JournalEntry]()
            for document in snapshot.documents {
                let journalEntry = try document.data(as: JournalEntry.self)
                temp.append(journalEntry)
            }
            entriesForSelectedDate = temp
        } catch {
            print("Error in \(#function)\n\(error)")
        }
            
    }

    /// Gets the journal entries for the given `habit`.
    func getJournalEntries(inMonthOf date: Date) async {
        precondition(userSession.isSignedIn, "User is not signed in ")
        guard let user = userSession.currentUser else { return }

        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let monthDates: [Date] = calendar.range(of: .day, in: .month, for: monthStart)!.compactMap { day -> Date in
            calendar.date(byAdding: .day, value: day, to: monthStart)!
        }
        
        let query = firestore
            .collection("journalEntries")
            .document(user.uid)
            .collection(habit.id)
            .whereField("dateCreated", isGreaterThanOrEqualTo: monthDates.first!)
            .whereField("dateCreated", isLessThanOrEqualTo: monthDates.last!)
            .limit(to: maxQueryLimit)
        
        do {
            let snapshot = try await query.getDocuments()
            var temp = [JournalEntry]()
            for document in snapshot.documents {
                let journalEntry = try document.data(as: JournalEntry.self)
                temp.append(journalEntry)
            }
            clearSelectedEntries() // entries are cleared so that the view doesn't display old entries for a different month
            journalEntries = temp
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    /// Returns true if the given date is associated with a journal entry.
    /// - parameter date: The date to look for in the journal.
    func journalHasEntry(for date: Date) -> Bool {
        for entry in journalEntries {
            if entry.dateCreated.isEqual(to: date) {
                return true
            }
        }
        return false
    }

    /// Clears the entries in the current `entriesForSelectedDate` array.
    func clearSelectedEntries() {
        entriesForSelectedDate = []
    }
}

private extension HabitCalendarViewModel {
    
}
