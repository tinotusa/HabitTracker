//
//  SignUpViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 17/5/2022.
//

import FirebaseAuth
import FirebaseFirestore

class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailConfirmation = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    @Published var birthday = Date()
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var isLoading = false
    @Published var didError = false
    @Published var errorDetails: ErrorDetails? {
        didSet {
            didError = true
        }
    }
    private let auth = Auth.auth()
    private var firestore = Firestore.firestore()
    
    var allFieldsFilled: Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailConfirmation = emailConfirmation.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordConfirmation = passwordConfirmation.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !(
            email.isEmpty || emailConfirmation.isEmpty ||
            password.isEmpty || passwordConfirmation.isEmpty ||
            firstName.isEmpty || lastName.isEmpty
        )
    }
    
    @MainActor
    func createAccount(session: UserSession) {
        assert(allFieldsFilled, "All input fields must be filled")
        isLoading = true
        defer {
            isLoading = false
        }
        
        if password != passwordConfirmation {
            errorDetails = ErrorDetails(
                name: "Password mismatch",
                message: "The passwords provided to not match each other"
            )
            return
        }
        if email != emailConfirmation {
            errorDetails = ErrorDetails(
                name: "Email mismatch",
                message: "The emails provided to not match each other"
            )
            return
        }
        
        auth.createUser(withEmail: email, password: password) { [unowned self] authResult, error in
            if let error = error {
                print("Error failed to create user with email: \(email)\n\(error.localizedDescription)")
                errorDetails = ErrorDetails(
                    name: "Account error",
                    message: error.localizedDescription
                )
                return
            }
            guard let authResult = authResult else {
                print("Error in \(#function): failed to get auth data result from create user")
                return
            }

            let firebaseUser = FirebaseUser(
                firstName: firstName,
                lastName: lastName,
                email: email,
                birthday: birthday
            )
            
            let userRef = self.firestore.collection("users").document(authResult.user.uid)
            do {
                try userRef.setData(from: firebaseUser)
            } catch {
                print("Error in \(#function)\n\(error)")
                errorDetails = ErrorDetails(
                    name: "Account error",
                    message: error.localizedDescription
                )
                return
            }

            session.currentUser = authResult.user
            session.signedIn = true
        }
    }
}
