//
//  HomeViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 28/5/2022.
//

import FirebaseFunctions
import FirebaseFirestore

@MainActor
final class HomeViewViewModel: ObservableObject {
    /// The habits to be displayed.
    @Published var habits = [Habit]()
    /// A boolean value indicating wheter the database has more data in the list.
    @Published var hasNextPage = false
    /// A boolean value indicating whether the database has more data.
    @Published var hasPreviousPage = false
    /// A boolean value indicating whether the account termination confirmation dialog is displayed.
    @Published var showingAccountTerminationDialog = false
    
    private lazy var firestore = Firestore.firestore()
    private lazy var functions = Functions.functions(region: "australia-southeast1")
    
    /// The next document to be queried from.
    private var nextDocument: DocumentSnapshot? {
        didSet {
            if nextDocument == nil {
                hasNextPage = false
            } else {
                hasNextPage = true
            }
        }
    }
    
    /// The previous document to be queried from.
    private var previousDocument: DocumentSnapshot? {
        didSet {
            if previousDocument == nil {
                hasPreviousPage = false
            } else {
                hasPreviousPage = true
            }
        }
    }
    
    /// The max query limit for habits.
    private let maxQueryLimit = 10
}

extension HomeViewViewModel {
    /// Gets the habits from the database.
    /// - parameter userSession: The current user that is logged in.
    func getHabits(userSession: UserSession) async {
        guard let user = userSession.currentUser else {
            preconditionFailure("User is not logged in.")
        }
        let query = firestore
            .collectionGroup("habits")
            .whereField("createdBy", isEqualTo: user.uid)
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
        guard let user = userSession.currentUser else {
            preconditionFailure("User is not logged in.")
        }
        guard let nextDocument = nextDocument else { return }
        
        let query = firestore
            .collectionGroup("habits")
            .whereField("createdBy", isEqualTo: user.uid)
            .order(by: "createdAt")
            .start(atDocument: nextDocument)
            .limit(to: maxQueryLimit)

        do {
            let snapshot = try await query.getDocuments()
            previousDocument = nextDocument
//            habits = []
            self.nextDocument = snapshot.documents.last

            for document in snapshot.documents {
                let habit = try document.data(as: Habit.self)
                habits.append(habit)
            }

            if self.nextDocument != nil {
                let nextPageQuery = firestore
                    .collectionGroup("habits")
                    .whereField("createdBy", isEqualTo: user.uid)
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
        guard let user = userSession.currentUser else {
            preconditionFailure("User is not logged in.")
        }
        guard let previousDocument = previousDocument else { return }
  
        let query = firestore
            .collectionGroup("habits")
            .whereField("createdBy", isEqualTo: user.uid)
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
                    .whereField("createdBy", isEqualTo: user.uid)
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
    
    /// Deletes the user from the database.
    /// - parameter userSession: The current user that is logged in.
    func deleteUser(userSession: UserSession) async {
        guard let user = userSession.currentUser else {
            preconditionFailure("User is not logged in")
        }
        do {
            // Remove the pending notifications.
            let allHabitsQueryLlimit = 100
            var notificationIDS = [String]()
            let query = firestore
                .collectionGroup("habits")
                .whereField("createdBy", isEqualTo: user.uid)
                .limit(to: allHabitsQueryLlimit)
            
            let snapshot = try await query.getDocuments()
            
            for document in snapshot.documents {
                if let id1 = document.get("localNotificationID") as? String {
                    notificationIDS.append(id1)
                }
                if let id2 = document.get("localReminderNotificationID") as? String {
                    notificationIDS.append(id2)
                }
            }
            NotificationManager.removePendingNotifications(withIdentifiers: notificationIDS)
            
            // Delete documents associated with the user and sign out.
            let _ = try await functions.httpsCallable("deleteUser").call(["userID": user.uid])
            userSession.signOut()
            try await user.delete()
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
}
