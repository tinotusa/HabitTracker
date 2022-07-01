//
//  SignUpView.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SignUpViewModel()
    @FocusState private var inputField: SignUpViewModel.InputField?
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                backButton
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Constants.vstackSpacing) {
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
                        
                        signUpButton
                    }
                    .frame(minHeight: proxy.size.height)
                }
            }
            .padding()
            .backgroundView()
            .disabled(viewModel.isLoading)
            .navigationBarHidden(true)
            .actionNotification(
                text: "Creating account...",
                showingNotifiction: $viewModel.showActionNotification,
                canTapToHide: false,
                willDisappearWhenFalse: $viewModel.isLoading
            )
            .actionNotification(
                text: "Account created.",
                icon: "checkmark.circle.fill",
                showingNotifiction: $viewModel.showActionNotification
            )
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
            .onChange(of: viewModel.firstName) { name in
                viewModel.checkFirstNameCharLimit(name: name)
            }
            .inputField(contentType: .givenName) {
                nextField()
            }
    }
    
    var lastNameInput: some View {
        TextField("Last name", text: $viewModel.lastName, prompt: Text(viewModel.lastNamePrompt))
            .focused($inputField, equals: .lastName)
            .onChange(of: viewModel.lastName) { name in
                viewModel.checkLastNameCharLimit(name: name)
            }
            .inputField(contentType: .familyName) {
                nextField()
            }
    }
    
    var emailInput: some View {
        TextField("Email", text: $viewModel.email, prompt: Text(viewModel.emailPrompt))
            .focused($inputField, equals: .email)
            .onChange(of: viewModel.email) { email in
                viewModel.checkEmailCharLimit(email: email)
            }
            .inputField(imageName: "envelope.fill", contentType: .emailAddress) {
                nextField()
            }
    }
    
    var emailConfirmationInput: some View {
        TextField("Email Confirmation", text: $viewModel.emailConfirmation, prompt: Text(viewModel.emailConfirmationPrompt))
            .focused($inputField, equals: .emailConfirmation)
            .inputField(imageName: "envelope.fill", contentType: .emailAddress)
            .onChange(of: viewModel.emailConfirmation) { email in
                viewModel.checkEmailConfirmationCharLimit(email: email)
            }
    }
    
    var passwordInput: some View {
        SecureField("Password", text: $viewModel.password, prompt: Text(viewModel.passwordPrompt))
            .passwordField(contentType: .newPassword) {
                nextField()
            }
            .focused($inputField, equals: .password)
            .onChange(of: viewModel.password) { password in
                viewModel.checkPasswordCharLimit(password: password)
            }
    }
    
    var passwordConfirmationInput: some View {
        SecureField("Password Confirmation", text: $viewModel.passwordConfirmation, prompt: Text(viewModel.passwordConfirmationPrompt))
            .passwordField(contentType: .newPassword) {
                nextField()
            }
            .focused($inputField, equals: .passwordConfirmation)
            .onChange(of: viewModel.passwordConfirmation) { password in
                viewModel.checkPasswordConfirmationCharLimit(password: password)
            }
    }
    
    var birthdayInput: some View {
        DatePicker("Birthday", selection: $viewModel.birthday, in: ...Date(), displayedComponents: [.date])
            .title2Style()
    }
    
    // MARK: - Buttons
    var doneButton: some View {
        Button("Done") {
            createAccount()
        }
        .disabled(!viewModel.allFieldsFilled)
    }
    
    var signUpButton: some View {
        LongButton(text: "Sign up") {
            createAccount()
        }
        .disabled(!viewModel.allFieldsFilled)
    }
    
    var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(.textColour)
                Text("Back")
                    .title2Style()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.backgroundColour)
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
