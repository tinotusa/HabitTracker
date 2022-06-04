//
//  EditHabitViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 4/6/2022.
//

import FirebaseFirestore

@MainActor
final class EditHabitViewViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var didError = false
    @Published var errorDetails: ErrorDetails? {
        didSet {
            if errorDetails != nil {
                didError = true
            }
        }
    }
    @Published var hasSavedSuccessfully = false
    private lazy var firestore = Firestore.firestore()
    
    @discardableResult
    func saveHabit(_ habit: Habit, userSession: UserSession) -> Bool {
        precondition(userSession.isSignedIn, "User is not signed in.")
        guard let user = userSession.currentUser else { return false }
        
        let docRef = firestore.collection("habits")
            .document(user.uid)
            .collection("habits")
            .document(habit.id)
        
        do {
            try docRef.setData(from: habit, merge: true)
            hasSavedSuccessfully = true
            // cancel all notifications
            // readd all notifications
        } catch {
            errorDetails = ErrorDetails(
                name: "Save Error",
                message: "Failed to save changes. Please try again."
            )
            print("Error \(error)")
        }
        return true
    }
}
