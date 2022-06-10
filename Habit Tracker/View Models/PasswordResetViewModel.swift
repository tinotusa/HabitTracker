//
//  PasswordResetViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 10/6/2022.
//

import Foundation
import FirebaseAuth

class PasswordResetViewModel: ObservableObject {
    @Published var email = ""
    @Published var didError = false
    @Published var errorDetails: ErrorDetails? {
        didSet {
            if errorDetails != nil {
                didError = true
            }
        }
    }
    
    let emailPlaceholder = "Enter your account's email"
    
    private lazy var auth = Auth.auth()
}

extension PasswordResetViewModel {
    var allFieldsFilled: Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return !email.isEmpty
    }
    
    func sendResetEmail() {
        auth.sendPasswordReset(withEmail: email) { [unowned self] error in
            if let error = error {
                errorDetails = ErrorDetails(
                    name: "Password reset error",
                    message: "\(error.localizedDescription)"
                )
                return
            }
        }
    }
}
