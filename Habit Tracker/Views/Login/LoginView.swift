//
//  LoginView.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    enum Field: Hashable {
        case username
        case password
    }
    @FocusState var field: Field?
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("Login view")
                    
                    signInWithAppleButton
                    
                    signInWithGoogleButton
                    
                    horizontalDivider
                    
                    TextField("Email", text: $viewModel.email, prompt: Text("Email"))
                        .textContentType(.emailAddress)
                        .focused($field, equals: .username)
                        .submitLabel(.next)
                        .onSubmit {
                            field = .password
                        }
                    SecureField("Password", text: $viewModel.password, prompt: Text("Password"))
                        .textContentType(.password)
                        .focused($field, equals: .password)
                        .submitLabel(.done)
                        .onSubmit {
                            signIn()
                        }
                    Button {
                        viewModel.showPasswordResetView = true
                    } label: {
                        Text("Forgot email or password?")
                            .font(.subheadline)
                    }
                    Button("Login") {
                        signIn()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.allFieldsFilled)
                    
                    Button("Sign up") {
                        viewModel.showSignUpView = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .disabled(userSession.isLoading)
                .textFieldStyle(.roundedBorder)
                .padding()
                .frame(width: proxy.size.width)
                .frame(minHeight: proxy.size.height)
            }
            .overlay {
                LoadingView(placeholder: "Logging in", isLoading: $userSession.isLoading)
            }
            .fullScreenCover(isPresented: $viewModel.showSignUpView) {
                SignUpView()
            }
            .fullScreenCover(isPresented: $viewModel.showPasswordResetView) {
                PasswordResetView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    // up arrow
                    Button {
                        switch field {
                        case .password: field = .username
                        default: break
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    // down arrow
                    Button {
                        switch field {
                        case .username: field = .password
                        default: break
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                    }
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
        }
    }
}

// MARK: Functions and subviews
private extension LoginView {
    func signIn() {
        userSession.signIn(withEmail: viewModel.email, password: viewModel.password)
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
        .frame(maxHeight: 60)
    }
    
    var signInWithGoogleButton: some View {
        GoogleSignInButton()
            .onTapGesture {
                Task {
                    await userSession.googleLogin()
                }
            }
            .frame(maxHeight: 60)
    }
    
    var horizontalDivider: some View {
        HStack {
            VStack {
                Divider()
            }
            Text("or")
                .foregroundColor(.secondary)
            VStack {
                Divider()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserSession())
    }
}
