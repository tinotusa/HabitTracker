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
    @FocusState private var inputField: SignUpViewModel.InputField?
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Text("Sign up view??")
                Group {
                    TextField("First name", text: $viewModel.firstName, prompt: Text("First name"))
                        .textContentType(.givenName)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .onSubmit {
                            nextField()
                        }
                        .focused($inputField, equals: .firstName)
                    TextField("Last name", text: $viewModel.lastName, prompt: Text("Last name"))
                        .textContentType(.familyName)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .onSubmit {
                            nextField()
                        }
                        .focused($inputField, equals: .lastName)
                }
                
                Group {
                    TextField("Email", text: $viewModel.email, prompt: Text("Email"))
                        .textContentType(.emailAddress)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .onSubmit {
                            nextField()
                        }
                        .focused($inputField, equals: .email)
                    TextField("Email", text: $viewModel.emailConfirmation, prompt: Text("Email confirmation"))
                        .textContentType(.emailAddress)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .onSubmit {
                            nextField()
                        }
                        .focused($inputField, equals: .emailConfirmation)
                }
                
                Group {
                    SecureField("Password", text: $viewModel.password, prompt: Text("Password"))
                        .textContentType(.newPassword)
                        .submitLabel(.next)
                        .onSubmit {
                            nextField()
                        }
                        .focused($inputField, equals: .password)
                    SecureField("Password Confirmation", text: $viewModel.passwordConfirmation, prompt: Text("Password confirmation"))
                        .textContentType(.newPassword)
                        .submitLabel(.next)
                        .onSubmit {
                            nextField()
                        }
                        .focused($inputField, equals: .passwordConfirmation)
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
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        previousField()
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(inputField?.isFirstField ?? false)
                    Button {
                        nextField()
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(inputField?.isLastField ?? false)
                    Button("Done2") {
                        createAccount()
                    }
                    .disabled(!viewModel.allFieldsFilled)
                }
            }
        }
    }
}

// MARK: Views
private extension SignUpView {
    
}

// MARK: - Functions
private extension SignUpView {
    func nextField() {
        inputField = inputField?.nextField()
    }
    
    func previousField() {
        inputField = inputField?.previousField()
    }

    func createAccount() {
        viewModel.createAccount(session: userSession)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(UserSession())
    }
}
