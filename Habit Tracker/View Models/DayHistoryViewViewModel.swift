//
//  DayHistoryViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 1/6/2022.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFunctions


@MainActor
final class DayHistoryViewViewModel: ObservableObject {
    @Published var journalEntries = [JournalEntry]()
    private lazy var firestore = Firestore.firestore()
    private lazy var functions = Functions.functions(region: "australia-southeast1")
    private var maxQueryLimit = 50
    
    var hasEntries: Bool {
        !journalEntries.isEmpty
    }
}

extension DayHistoryViewViewModel {
    func getHabits(for date: Date, userSession: UserSession) async {
        guard let user = userSession.currentUser else {
            preconditionFailure("User is not logged in.")
        }
        do {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let startDate = calendar.date(from: components)!
            let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            
            var temp = [JournalEntry]()
            let query = firestore
                .collectionGroup("journalEntries")
                .whereField("createdBy", isEqualTo: user.uid)
                .whereField("dateCreated", isGreaterThanOrEqualTo: startDate)
                .whereField("dateCreated", isLessThanOrEqualTo: endDate)
                .limit(to: maxQueryLimit)
            
            let snapshot = try await query.getDocuments()
            for document in snapshot.documents {
                let entry = try document.data(as: JournalEntry.self)
                temp.append(entry)
            }
            journalEntries = temp
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
}
