//
//  LoginView.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import GoogleSignIn
import Firebase 

struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("Login view")
                    // sign in with apple
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
                    
                    // sign in with google
                    GoogleSignInButton()
                        .onTapGesture {
                            Task {
                                await userSession.googleLogin()
                            }
                        }
                        .frame(maxHeight: 60)
                    
                    // -- or --
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
                    
                    TextField("Email", text: $viewModel.email, prompt: Text("Email"))
                        .textContentType(.emailAddress)
                    TextField("Password", text: $viewModel.password, prompt: Text("Password"))
                        .textContentType(.password)
                    Button {
                        viewModel.showPasswordResetView = true
                    } label: {
                        Text("Forgot email or password?")
                            .font(.subheadline)
                    }
                    Button("Login") {
                        userSession.signIn(withEmail: viewModel.email, password: viewModel.password)
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserSession())
    }
}
