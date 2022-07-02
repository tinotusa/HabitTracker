//
//  HabitCalendarViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 30/5/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions
import SwiftUI

@MainActor
final class HabitCalendarViewModel: ObservableObject {
    var habit: Habit!
    var userSession: UserSession!
    
    @Published var journalEntries = [JournalEntry]()
    @Published var entriesForSelectedDate = [JournalEntry]()
    @Published var showingDeleteConfirmation = false
    
    @Published var isLoading = false
    @Published var showingActionNotification = false
    
    private lazy var firestore = Firestore.firestore()
    private lazy var functions = Functions.functions(region: "australia-southeast1")
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
            .collection("journalEntries")
            .whereField("createdBy", isEqualTo: user.uid)
            .whereField("habitID", isEqualTo: habit.id)
            .whereField("dateCreated", isGreaterThanOrEqualTo: startDate)
            .whereField("dateCreated", isLessThanOrEqualTo: endDate)
            .limit(to: maxQueryLimit)

        do {
            let snapshot = try await query.getDocuments()
            var temp = [JournalEntry]()
            for document in snapshot.documents {
                do {
                    let journalEntry = try document.data(as: JournalEntry.self)
                    temp.append(journalEntry)
                } catch {
                    print("Error in \(#function)\n\(error)")
                }
            }
            entriesForSelectedDate = temp
        } catch {
            print("Error in \(#function)\n\(error)")
        }
            
    }

    /// Gets the journal entries for the given `habit`.
    ///  - parameter month: The month to get journal entries from.
    func getJournalEntries(inMonthOf month: Date) async {
        precondition(userSession.isSignedIn, "User is not signed in ")
        guard let user = userSession.currentUser else { return }

        let calendar = Calendar.current
        let dateComps = calendar.dateComponents([.month, .year], from: month)
        guard let monthStart = calendar.date(from: dateComps) else {
            print("Error in \(#function). Failed create date from date components")
            return
        }
        guard let range = calendar.range(of: .day, in: .month, for: month) else {
            print("Error in \(#function). Failed range from date month")
            return
        }
        var arr = [Int](range)
        arr.insert(0, at: 0)
    
        let monthDates = arr.compactMap { day in
            calendar.date(byAdding: .day, value: day, to: monthStart)
        }
        
        let query = firestore
            .collection("journalEntries")
            .document(user.uid)
            .collection("journalEntries")
            .whereField("createdBy", isEqualTo: user.uid)
            .whereField("habitID", isEqualTo: habit.id)
            .whereField("dateCreated", isGreaterThanOrEqualTo: monthDates.first!)
            .whereField("dateCreated", isLessThanOrEqualTo: monthDates.last!)
            .limit(to: maxQueryLimit)
        
        do {
            let snapshot = try await query.getDocuments()
            var temp = [JournalEntry]()
            for document in snapshot.documents {
                do {
                    let journalEntry = try document.data(as: JournalEntry.self)
                    temp.append(journalEntry)
                } catch {
                    print("Error in \(#function)\n\(error)")
                }
            }
            clearSelectedEntries() // entries are cleared so that the view doesn't display old entries for a different month
            journalEntries = temp
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    /// Returns true if the given date is associated with a journal entry.
    /// - parameter date: The date to look for in the journal.
    /// - returns: `True` if the given `date` has a journal entry, `False` otherwise.
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
    
    /// Gets habit with the specified id.
    /// - parameter id: The id of the habit to get.
    /// - parameter userSession: The current user session.
    /// - returns: The habit that was retrieved from firestore.
    func getHabit(id: String, userSession: UserSession) async -> Habit {
        precondition(userSession.isSignedIn, "User is not singed in.")
        guard let user = userSession.currentUser else { fatalError("User is not signed in") }
        let docRef = firestore.collection("habits")
            .document(user.uid)
            .collection("habits")
            .document(id)
        
        do {
            let snapshot = try await docRef.getDocument()
            let habit = try snapshot.data(as: Habit.self)
            return habit
        } catch {
            print("\(error)")
        }
        fatalError("No habit found") // TODO: is this a good idea? under what circumstance can this happen?
    }
    
    /// Deletes a habit from the database.
    /// - parameter habit: The habit to delete.
    /// - parameter userSession: The current user session.
    func delete(habit: Habit, userSession: UserSession) async {
        withAnimation(.spring()) {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }
        precondition(userSession.isSignedIn, "User is not logged in.")
        guard let user = userSession.currentUser else {
            preconditionFailure("User is not logged in.")
        }
        do {
            let _ = try await functions.httpsCallable("deleteHabit").call([
                "userID": user.uid,
                "habitPath": "habits/\(user.uid)/habits/\(habit.id)",
                "habitID": habit.id
            ])
            NotificationManager.removePendingNotifications(withIdentifiers: [habit.localNotificationID, habit.localReminderNotificationID])
            withAnimation(.spring()) {
                showingActionNotification = true
            }
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
}
