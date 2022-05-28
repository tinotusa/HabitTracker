//
//  HomeViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 28/5/2022.
//

import FirebaseFirestore

@MainActor
final class HomeViewViewModel: ObservableObject {
    @Published var habits: [Habit]
    @Published var hasNextPage = false
    @Published var hasPreviousPage = false
    
    private lazy var firestore = Firestore.firestore()
    private var nextDocument: DocumentSnapshot? {
        didSet {
            if nextDocument == nil {
                hasNextPage = false
            } else {
                hasNextPage = true
            }
        }
    }
    private var previousDocument: DocumentSnapshot? {
        didSet {
            if previousDocument == nil {
                hasPreviousPage = false
            } else {
                hasPreviousPage = true
            }
        }
    }
    private let maxQueryLimit = 10
    
    init() {
        habits = []
    }
}

private extension HomeViewViewModel {
    
}

extension HomeViewViewModel {
    /// Gets the habits from the database.
    /// - parameter userSession: The current user that is logged in.
    func getHabits(userSession: UserSession) async {
        precondition(userSession.currentUser != nil, "User is not logged in")
        let query = firestore
            .collectionGroup("habits")
            .order(by: "createdAt")
            .limit(to: maxQueryLimit)
        /*
         p       l
         1 2 3 4 5 1 2 3 4 5
         */
        do {
            let snapshot = try await query.getDocuments()
            nextDocument = snapshot.documents.last
            previousDocument = snapshot.documents.first
            
            for document in snapshot.documents {
                let habit = try document.data(as: Habit.self)
                habits.append(habit)
            }
        } catch {
            print("Error in \(#function): \(error)")
        }
    }

//    /// Gets the next page of habits.
//    /// - parameter userSession: The current user that is logged in.
//    func getNextHabits(userSession: UserSession) async {
//        precondition(userSession.currentUser != nil, "User is not logged in.")
//        if nextDocument == nil { return }
//        let query = firestore
//            .collectionGroup("habits")
//            .order(by: "createdAt")
//            .start(afterDocument: nextDocument!)
//            .limit(to: maxQueryLimit)
//        /*
//                   p       l
//         1 2 3 4 5 1 2 3 4 5
//         */
//        do {
//            let snapshot = try await query.getDocuments()
//            previousDocument = snapshot.documents.first
//            nextDocument = snapshot.documents.last
//            if !snapshot.documents.isEmpty {
////                previousDocument = snapshot.documents.first
//                habits = []
//            }
//            for document in snapshot.documents {
//                let habit = try document.data(as: Habit.self)
//                habits.append(habit)
//            }
//        } catch {
//            print("Error in \(#function)\n\(error)")
//        }
//    }
//    
//    /// Gets the previous page of habits.
//    /// - parameter userSession: The current user that is logged in.
//    func getPreviousHabits(userSession: UserSession) async {
//        precondition(userSession.currentUser != nil, "User is not logged in.")
//        if previousDocument == nil { return }
//        let query = firestore
//            .collectionGroup("habits")
//            .order(by: "createdAt", descending: true)
//            .start(afterDocument: previousDocument!)
//            .limit(to: maxQueryLimit)
//        
//        /*
//         p       l       l
//         1 2 3 4 5 1 2 3 4 5
//         */
//        do {
//            let snapshot = try await query.getDocuments()
//            nextDocument = snapshot.documents.last
//            previousDocument = snapshot.documents.last
//            if !snapshot.documents.isEmpty {
//                habits = []
//            }
//            for document in snapshot.documents {
//                let habit = try document.data(as: Habit.self)
//                habits.append(habit)
//            }
//            if !snapshot.documents.isEmpty {
//                previousDocument = nil
//                habits.reverse()
//            }
//        } catch {
//            print("Error in \(#function)\n\(error)")
//        }
//    }
}
