//
//  SignUpViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 17/5/2022.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

/// Sign up view model.
class SignUpViewModel: ObservableObject {
    /// The users email.
    @Published var email = ""
    /// The users email confirmation.
    @Published var emailConfirmation = ""
    /// The users password.
    @Published var password = ""
    /// The users password confirmation.
    @Published var passwordConfirmation = ""
    /// The users birthday.
    @Published var birthday = Date()
    /// The users first name.
    @Published var firstName = ""
    /// The users last name.
    @Published var lastName = ""
    /// Value to indicate when some action is loading.
    @Published var isLoading = false
    /// Value to indicate when something errors.
    @Published var didError = false
    /// The information about the error.
    @Published var errorDetails: ErrorDetails? {
        didSet {
            didError = true
        }
    }
    /// A boolean value indicating whether or not to show the action notification.
    @Published var showActionNotification = false
    
    let firstNamePrompt: LocalizedStringKey = "First name"
    let lastNamePrompt: LocalizedStringKey = "Last name"
    let emailPrompt: LocalizedStringKey = "Email"
    let emailConfirmationPrompt: LocalizedStringKey = "Email confirmation"
    let passwordPrompt: LocalizedStringKey = "Password"
    let passwordConfirmationPrompt: LocalizedStringKey = "Password confirmation"
    
    private let auth = Auth.auth()
    private var firestore = Firestore.firestore()
    
    /// A boolean value indicating whether the input fields have some text.
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
    /// Creates a new account with the given information(name, email, password, etc).
    func createAccount(session: UserSession) async {
        assert(allFieldsFilled, "All input fields must be filled")
        withAnimation(.spring()) {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
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
        
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            let firebaseUser = FirebaseUser(
                id: authResult.user.uid,
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
                    message: "\(error.localizedDescription)"
                )
                return
            }
            
            withAnimation(.spring()) {
                showActionNotification = true
            }
            
            clearFields()
            
        } catch {
            print("Error failed to create user with email: \(email)\n\(error.localizedDescription)")
            errorDetails = ErrorDetails(
                name: "Account error",
                message: "\(error.localizedDescription)"
            )
            return
        }
    }
    
    /// Sets all the input fields to their default values (empty strings).
    func clearFields() {
        DispatchQueue.main.async { [weak self] in
            self?.email = ""
            self?.emailConfirmation = ""
            self?.password = ""
            self?.passwordConfirmation = ""
            self?.birthday = Date()
            self?.firstName = ""
            self?.lastName = ""
        }
    }
}

// MARK: - Input Field char limits
extension SignUpViewModel {
    func checkFirstNameCharLimit(name: String) {
        firstName = Constants.limit(text: name, to: InputFieldCharLimit.name)
    }
    
    func checkLastNameCharLimit(name: String) {
        lastName = Constants.limit(text: name, to: InputFieldCharLimit.name)
    }
    
    func checkEmailCharLimit(email: String) {
        self.email = Constants.limit(text: email, to: InputFieldCharLimit.email)
    
    }
    
    func checkEmailConfirmationCharLimit(email: String) {
        self.emailConfirmation = Constants.limit(text: email, to: InputFieldCharLimit.email)
    
    }
    
    func checkPasswordCharLimit(password: String) {
        self.password = Constants.limit(text: password, to: InputFieldCharLimit.password)
    }
    
    func checkPasswordConfirmationCharLimit(password: String) {
        self.passwordConfirmation = Constants.limit(text: password, to: InputFieldCharLimit.password)
    }
}

extension SignUpViewModel {
    /// Represents the input fields for the sign up view.
    enum InputField: Hashable {
        case firstName, lastName, email, emailConfirmation, password, passwordConfirmation
        
        /// Returns the next field or returns nil if it is currently the last field.
        func nextField() -> InputField? {
            switch self {
            case .firstName: return .lastName
            case .lastName: return .email
            case .email: return .emailConfirmation
            case .emailConfirmation: return .password
            case .password: return .passwordConfirmation
            case .passwordConfirmation: return nil
            }
        }
        
        /// Returns the previous field or returns nil if it is currently the first field.
        func previousField() -> InputField? {
            switch self {
            case .firstName: return nil
            case .lastName: return .firstName
            case .email: return .lastName
            case .emailConfirmation: return .email
            case .password: return .emailConfirmation
            case .passwordConfirmation: return .password
            }
        }
        
        /// Returns true if the current field is the first case (`firstName`).
        var isFirstField: Bool {
            self == .firstName
        }
        
        /// Returns true if the current field is the last case (`lastName`).
        var isLastField: Bool {
            self == .passwordConfirmation
        }
    }
}
