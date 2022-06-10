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
            ZStack(alignment: .topLeading) {
                Color("backgroundColour")
                    .ignoresSafeArea()
                
                backButton
                    
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Text("Register")
                            .titleStyle()
                        
                        Group {
                            firstNameInput
                            
                            lastNameInput
                            
                            emailInput
                           
                            emailConfirmationInput
                            
                            passwordInput
                            
                            passwordConfirmationInput
                        }
                        
                        birthdayInput
                        
                        signUpButton(proxy: proxy)
                            
                    }
                    .frame(minHeight: proxy.size.height)
                    .padding()
                }
            }
            .disabled(viewModel.isLoading)
            .navigationBarHidden(true)
            .overlay {
                LoadingView(placeholder: "Creating account", isLoading: $viewModel.isLoading)
                    .frame(height: proxy.size.height)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    previousFieldButton
                    
                    nextFieldButton
                }
                
                doneButton
            }
        }
        .alert(
            viewModel.errorDetails?.name ?? "Something went wrong",
            isPresented: $viewModel.didError,
            presenting: viewModel.errorDetails
        ) { _ in
            // default ok button
        } message: { detail in
            Text(detail.message)
        }
    }
}

// MARK: - Views
private extension SignUpView {
    var firstNameInput: some View {
        TextField("First name", text: $viewModel.firstName, prompt: Text(viewModel.firstNamePrompt))
            .focused($inputField, equals: .firstName)
            .inputField(contentType: .givenName) {
                nextField()
            }
    }
    
    var lastNameInput: some View {
        TextField("Last name", text: $viewModel.lastName, prompt: Text(viewModel.lastNamePrompt))
            .focused($inputField, equals: .lastName)
            .inputField(contentType: .familyName) {
                nextField()
            }
    }
    
    var emailInput: some View {
        TextField("Email", text: $viewModel.email, prompt: Text(viewModel.emailPrompt))
            .inputField(imageName: "envelope.fill", contentType: .emailAddress) {
                nextField()
            }
            .focused($inputField, equals: .email)
    }
    
    var emailConfirmationInput: some View {
        TextField("Email Confirmation", text: $viewModel.emailConfirmation, prompt: Text(viewModel.emailConfirmationPrompt))
            .focused($inputField, equals: .emailConfirmation)
            .inputField(imageName: "envelope.fill", contentType: .emailAddress)
    }
    
    var passwordInput: some View {
        SecureField("Password", text: $viewModel.password, prompt: Text(viewModel.passwordPrompt))
            .passwordField(contentType: .newPassword) {
                nextField()
            }
            .focused($inputField, equals: .password)
    }
    
    var passwordConfirmationInput: some View {
        SecureField("Password Confirmation", text: $viewModel.passwordConfirmation, prompt: Text(viewModel.passwordConfirmationPrompt))
            .passwordField(contentType: .newPassword) {
                nextField()
            }
            .focused($inputField, equals: .passwordConfirmation)
    }
    
    var birthdayInput: some View {
        DatePicker("Birthday", selection: $viewModel.birthday, in: ...Date(), displayedComponents: [.date])
            .bodyStyle()
    }
    
    // MARK: - Buttons
    var doneButton: some View {
        Button("Done") {
            createAccount()
        }
        .disabled(!viewModel.allFieldsFilled)
    }
    
    @ViewBuilder
    func signUpButton(proxy: GeometryProxy) -> some View {
        Button {
            createAccount()
        } label: {
            Text("Sign up")
        }
        .buttonStyle(LongButtonStyle(proxy: proxy))
        .disabled(!viewModel.allFieldsFilled)
    }
    
    var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(Color("textColour"))
                Text("Back")
                    .bodyStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color("backgroundColour"))
        .padding(.leading)
        .zIndex(1)
    }
    
    @ViewBuilder
    var previousFieldButton: some View {
        Button {
            previousField()
        } label: {
            Image(systemName: "chevron.up")
        }
        .disabled(inputField?.isFirstField ?? false)
    }
    
    @ViewBuilder
    var nextFieldButton: some View {
        Button {
            nextField()
        } label: {
            Image(systemName: "chevron.down")
        }
        .disabled(inputField?.isLastField ?? false)
    }
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
