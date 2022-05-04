//
//  PasswordResetView.swift
//  Habit Tracker
//
//  Created by Tino on 3/5/2022.
//

import SwiftUI
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
    
    private lazy var auth = Auth.auth()

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

struct PasswordResetView: View {
    @StateObject var viewModel = PasswordResetViewModel()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("Password reset view")
            TextField("Email", text: $viewModel.email, prompt: Text("Email"))
            Button("Send reset email") {
                viewModel.sendResetEmail()
            }
            Button("Back") {
                dismiss()
            }
        }
        .alert(
            "Password reset error",
            isPresented: $viewModel.didError,
            presenting: viewModel.errorDetails
        ) { detail in
            Button(role: .cancel) {
                // something
            } label: {
                Text("OK")
            }
        } message: { details in
            Text(details.message)
        }
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
