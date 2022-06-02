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
        precondition(userSession.isSignedIn, "User is not logged in")
        let query = firestore
            .collectionGroup("habits")
            .order(by: "createdAt")
            .limit(to: maxQueryLimit)

        do {
            let snapshot = try await query.getDocuments()
            nextDocument =  snapshot.documents.count < maxQueryLimit ? nil : snapshot.documents.last
            previousDocument = nil
            var tempHabits = [Habit]()
            for document in snapshot.documents {
                let habit = try document.data(as: Habit.self)
                tempHabits.append(habit)
            }
            habits = tempHabits
        } catch {
            print("Error in \(#function): \(error)")
        }
    }

    /// Gets the next page of habits.
    /// - parameter userSession: The current user that is logged in.
    func getNextHabits(userSession: UserSession) async {
        precondition(userSession.isSignedIn, "User is not logged in")
        guard let nextDocument = nextDocument else { return }
        
        let query = firestore
            .collectionGroup("habits")
            .order(by: "createdAt")
            .start(atDocument: nextDocument)
            .limit(to: maxQueryLimit)

        do {
            let snapshot = try await query.getDocuments()
            previousDocument = nextDocument
            habits = []
            self.nextDocument = snapshot.documents.last

            for document in snapshot.documents {
                let habit = try document.data(as: Habit.self)
                habits.append(habit)
            }

            if self.nextDocument != nil {
                let nextPageQuery = firestore
                    .collectionGroup("habits")
                    .order(by: "createdAt")
                    .start(atDocument: self.nextDocument!)
                    .limit(to: maxQueryLimit)
                let nextPageSnapshot = try await nextPageQuery.getDocuments()
                if nextPageSnapshot.documents.count == 1 {
                    self.nextDocument = nil
                }
            }
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    /// Gets the previous page of habits.
    /// - parameter userSession: The current user that is logged in.
    func getPreviousHabits(userSession: UserSession) async {
        precondition(userSession.isSignedIn, "User is not signed in.")
        guard let previousDocument = previousDocument else { return }
  
        let query = firestore
            .collectionGroup("habits")
            .order(by: "createdAt", descending: true)
            .start(atDocument: previousDocument)
            .limit(to: maxQueryLimit)
            
        do {
            let snapshot = try await query.getDocuments()
            nextDocument = previousDocument
            self.previousDocument = snapshot.documents.last

            var tempHabits = [Habit]()
            for document in snapshot.documents {
                let habit = try document.data(as: Habit.self)
                tempHabits.append(habit)
            }
            
            if self.previousDocument != nil {
                let prevPageQuery = firestore
                    .collectionGroup("habits")
                    .order(by: "createdAt", descending: true)
                    .limit(to: maxQueryLimit)
                    .start(atDocument: self.previousDocument!)
                let prevPageSnapshot = try await prevPageQuery.getDocuments()
                
                if prevPageSnapshot.documents.count == 1 {
                    self.previousDocument = nil
                }
            }
            habits = tempHabits.reversed()
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
}
