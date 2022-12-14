//
//  LoginView.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import SwiftUI
import AuthenticationServices
//import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var field: LoginViewModel.InputField?
    @AppStorage("rememberMe") var rememberMe = false
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                NavigationLink(isActive: $viewModel.showSignUpView) {
                    SignUpView()
                } label: {
                    EmptyView()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Constants.vstackSpacing) {
                        Text("Habit tracker")
                            .titleStyle()
                        
                        emailInputField
                        
                        passwordInputField
                        
                        rememberMeButton
                        
                        loginButton
                        
                        signUpButton
                        
                        horizontalDivider
                        
                        signInWithAppleButton
                        
//                        signInWithGoogleButton
                        
                        forgotLoginDetailsButton
                    }
                    .padding()
                    .disabled(userSession.isLoading)
                    .frame(minHeight: proxy.size.height)
                }
                .backgroundView()
            }
            .navigationViewStyle(.stack)
            .navigationBarHidden(true)
            .disabled(userSession.isLoading)
            .onAppear {
                if rememberMe {
                    viewModel.getLoginDetails()
                }
            }
            .popover(isPresented: $viewModel.showPasswordResetView) {
                PasswordResetView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    keyboardUpArrow
                    keyboardDownArrow
                    keyboardDoneButton
                }
            }
            .alert(
                userSession.errorDetails?.name ?? "Login error",
                isPresented: $userSession.didError,
                presenting: userSession.errorDetails
            ) { details in
                // default ok button
            } message: { details in
                Text(details.message)
            }
            .actionNotification(
                text: "Logging in.",
                showingNotifiction: $userSession.showActionNotification,
                showProgressCircle: true,
                canTapToHide: false,
                willDisappearWhenFalse: $userSession.isLoading
            )
        }
    }
}

// MARK: - Subviews
private extension LoginView {
    var emailInputField: some View {
        TextField("Email", text: $viewModel.email, prompt: Text(viewModel.emailPlaceholder))
            .keyboardType(.emailAddress)
            .inputField(contentType: .emailAddress) {
                field = .password
            }
            .submitLabel(.next)
            .focused($field, equals: .username)
    }
    
    var passwordInputField: some View {
        SecureField("Password", text: $viewModel.password, prompt: Text(viewModel.passwordPlaceholder))
            .passwordField(contentType: .newPassword) {
                signIn()
            }
            .focused($field, equals: .password)
            .submitLabel(.done)
    }
    
    var rememberMeButton: some View {
        Toggle("Remember me", isOn: $rememberMe)
            .foregroundColor(.textColour)
            .title2Style()
    }
    
    var loginButton: some View {
        LongButton(text: "Login", isDisabled: !viewModel.allFieldsFilled) {
            if rememberMe {
                viewModel.saveLoginDetails()
            }
            Task {
                await userSession.signIn(withEmail: viewModel.email, password: viewModel.password)
            }
        }
    }
    
    var signUpButton: some View {
        LongButton(text: "Sign up") {
            viewModel.showSignUpView = true
        }
    }
    
    var horizontalDivider: some View {
        HStack {
            Rectangle().frame(height: 1)
            Text("or")
                .font(.subheadline)
            Rectangle().frame(height: 1)
        }
        .foregroundColor(.textColour.opacity(0.4))
    }
    
    var forgotLoginDetailsButton: some View {
        Button("Forgot your password?") {
            viewModel.showPasswordResetView = true
        }
    }
    
    // MARK: - Keyboard Buttons
    var keyboardUpArrow: some View {
        Button {
            switch field {
            case .password: field = .username
            default: break
            }
        } label: {
            Image(systemName: "chevron.up")
        }
        .disabled(field == .username)
    }
    
    var keyboardDownArrow: some View {
        Button {
            switch field {
            case .username: field = .password
            default: break
            }
        } label: {
            Image(systemName: "chevron.down")
        }
        .disabled(field == .password)
    }
    
    var keyboardDoneButton: some View {
        Button("Done") {
            signIn()
        }
        .disabled(!viewModel.allFieldsFilled)
    }
    
    
    var signInWithAppleButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let auth):
                Task {
                    await userSession.appleLogin(with: auth)
                }
            case .failure(let error):
                print(error)
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 60)
    }
    
//    var signInWithGoogleButton: some View {
//        GoogleSignInButton()
//            .onTapGesture {
//                Task {
//                    await userSession.googleLogin()
//                }
//            }
//            .frame(height: 60)
//    }
}

// MARK: Functions
private extension LoginView {
    func signIn() {
        Task {
            await userSession.signIn(withEmail: viewModel.email, password: viewModel.password)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserSession())
    }
}
