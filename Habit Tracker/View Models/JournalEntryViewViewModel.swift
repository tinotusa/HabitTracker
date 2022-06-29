//
//  JournalEntryViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 30/5/2022.
//

import Foundation
import FirebaseFirestore

/// JournalEntryView ViewModel.
@MainActor
final class JournalEntryViewViewModel: ObservableObject {
    /// The journal entry.
    @Published var entry = ""
    /// The rating of the day.
    @Published var rating = 0
    /// The list of activities the user wrote.
    @Published var activities = [JournalEntry.Activity]()
    
    private var firestore = Firestore.firestore()
}

extension JournalEntryViewViewModel {
    /// Adds the current entry to the database.
    func addEntry(userSession: UserSession, habit: Habit) {
        precondition(userSession.isSignedIn, "User is not logged in")
        guard let user = userSession.currentUser else { return }
        let journalRef = firestore
            .collection("journalEntries")
            .document(user.uid)
            .collection("journalEntries")
            .document()
        
        let journalEntry = JournalEntry(
            id: journalRef.documentID,
            createdBy: user.uid,
            habitID: habit.id,
            habitName: habit.name,
            entry: entry,
            activities: activities,
            rating: rating
        )
        do {
            try journalRef.setData(from: journalEntry)
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    /// Checks the length of the journal entry
    func checkEntryLength(entry: String) {
        self.entry = Constants.checkEntryLength(entry: entry)
    }
}
