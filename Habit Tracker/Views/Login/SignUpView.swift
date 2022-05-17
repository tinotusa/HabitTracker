//
//  SignUpView.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SignUpViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Text("Sign up view")
                Group {
                    TextField("First name", text: $viewModel.firstName, prompt: Text("First name"))
                        .textContentType(.givenName)
                    TextField("First name", text: $viewModel.lastName, prompt: Text("Last name"))
                        .textContentType(.familyName)
                }
                
                Group {
                    TextField("Email", text: $viewModel.email, prompt: Text("Email"))
                        .textContentType(.emailAddress)
                    TextField("Email", text: $viewModel.emailConfirmation, prompt: Text("Email confirmation"))
                        .textContentType(.emailAddress)
                }
                
                Group {
                    SecureField("Password", text: $viewModel.password, prompt: Text("Password"))
                        .textContentType(.password)
                    SecureField("Password Confirmation", text: $viewModel.passwordConfirmation, prompt: Text("Password confirmation"))
                        .textContentType(.password)
                }
                
                DatePicker("Birthday", selection: $viewModel.birthday, in: ...Date(), displayedComponents: [.date])
                
                HStack {
                    Button("Create Account") {
                        viewModel.createAccount(session: userSession)
                    }
                    .disabled(!viewModel.allFieldsFilled)
                    
                    Button("Back") {
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .disabled(viewModel.isLoading)
            .textFieldStyle(.roundedBorder)
            .padding()
            .overlay {
                LoadingView(placeholder: "Creating account", isLoading: $viewModel.isLoading)
                    .frame(height: proxy.size.height)
            }
            .alert(
                viewModel.errorDetails?.name ?? "Error",
                isPresented: $viewModel.didError,
                presenting: viewModel.errorDetails
            ) { _ in
                // default ok button
            } message: { detail in
                Text(detail.message)
            }
        }
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(UserSession())
    }
}
