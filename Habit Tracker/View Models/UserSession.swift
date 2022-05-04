//
//  UserSession.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import Firebase
import GoogleSignIn
import FirebaseFirestoreSwift
import AuthenticationServices

struct ErrorDetails: Identifiable {
    let id = UUID().uuidString
    var name: String
    var message: String
}

class UserSession: ObservableObject {
    @Published var signedIn = false
    @Published var currentUser: Firebase.User? = nil
    @Published var isLoading = false
    @Published var didError = false
    @Published var errorDetails: ErrorDetails? {
        didSet {
            if errorDetails != nil{
                didError = true
            }
        }
    }
    
    private lazy var auth = Auth.auth()
    private lazy var firestore = Firestore.firestore()
    
    init() {
        currentUser = auth.currentUser
        if currentUser != nil {
            Task {
                do {
                    let userRef = firestore.collection("users").document(currentUser!.uid)
                    let snapshot = try await userRef.getDocument()
                    if !snapshot.exists {
                        signedIn = false
                        return
                    }
                    signedIn = true
                } catch {
                    print(error)
                    errorDetails = ErrorDetails(name: "Login error", message: error.localizedDescription)
                }
            }
        }
    }
    
    var isSignedIn: Bool {
        return currentUser != nil
    }
    
    @MainActor
    func signIn(withEmail email: String, password: String) {
        isLoading = true
        defer {
            isLoading = false
        }
        auth.signIn(withEmail: email, password: password) { [unowned self] authResult, error in
            if error != nil {
                print("Error signing in with email: \(email)\n\(error?.localizedDescription ?? "")")
                errorDetails = ErrorDetails(name: "Login error", message: "\(error?.localizedDescription ?? "")")
                return
            }
            guard let authResult = authResult else {
                print("Error failed to get auth result with email: \(email)")
                errorDetails = ErrorDetails(name: "Authentication Error", message: "Failed to get authentication results from email: \(email)")
                return
            }
            self.currentUser = authResult.user
            self.signedIn = true
        }
    }
    
    @MainActor
    func googleLogin() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { [unowned self] user, error in
            if let error = error {
                print("Error: \(error)")
                errorDetails = ErrorDetails(name: "Google login error", message: "\(error.localizedDescription)")
                return
            }
            guard
                let auth = user?.authentication,
                let idToken = auth.idToken
            else {
                errorDetails = ErrorDetails(name: "Authentication error", message: "Failed to get user ID token.")
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: auth.accessToken)
            Task {
                let authResult = try await self.auth.signIn(with: credential)
                let userRef = self.firestore.collection("users").document(authResult.user.uid)
                
                do {
                    let snapshot = try await userRef.getDocument()
                    let user = GIDSignIn.sharedInstance.currentUser
                    if !snapshot.exists {
                        let user = FirebaseUser(
                            firstName: user?.profile?.givenName ?? "Not set",
                            lastName: user?.profile?.familyName ?? "Not set",
                            email: user?.profile?.email ?? "Not set",
                            birthday: Date()
                        )
                        try userRef.setData(from: user)
                    }
                } catch {
                    print(error)
                    errorDetails = ErrorDetails(name: "Google login error", message: "\(error.localizedDescription)")
                    
                }
                self.currentUser = authResult.user
                self.signedIn = true
            }
        }
    }
    
    @MainActor
    func appleLogin(with auth: ASAuthorization) async {
        isLoading = true
        defer {
            isLoading = false
        }
        guard let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential else {
            print("Failed to get apple ID credential")
            errorDetails = ErrorDetails(name: "Authentication error", message: "Failed to get apple ID credential.")
            
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to get identity token")
            errorDetails = ErrorDetails(name: "Authentication error", message: "Failed to get identity token.")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to get token string from data: \(appleIDToken.debugDescription)")
            errorDetails = ErrorDetails(name: "Authentication error", message: "Failed to get token.")
            return
        }
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            accessToken: nil
        )
        do {
            let authResult = try await self.auth.signIn(with: credential)
            
            let firstName = appleIDCredential.fullName?.givenName ?? "Not set"
            let lastName = appleIDCredential.fullName?.familyName ?? "Not set"
            let email = appleIDCredential.email ?? "Not set"
            
            let userRef = firestore.collection("users").document(authResult.user.uid)
            let snapshot = try await userRef.getDocument()
            if !snapshot.exists {
                let user = FirebaseUser(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    birthday: Date()
                )
                try userRef.setData(from: user)
            }
            self.currentUser = authResult.user
            self.signedIn = true
        } catch let error as NSError {
            print(error)
            errorDetails = ErrorDetails(name: "Authentication error", message: "\(error.localizedDescription)")
        }
    }
    
    @MainActor
    func signOut() {
        isLoading = true
        defer {
            isLoading = false
        }
        defer {
            signedIn = false
        }
        do {
            GIDSignIn.sharedInstance.signOut()
            try auth.signOut()
        } catch {
            print("Error in \(#function)\n\(error.localizedDescription)")
            errorDetails = ErrorDetails(name: "Sign out error", message: "\(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createAccount(withEmail email: String, password: String, user: FirebaseUser?) {
        isLoading = true
        defer {
            isLoading = false
        }
        auth.createUser(withEmail: email, password: password) { [unowned self] authResult, error in
            if let error = error {
                print("Error failed to create user with email: \(email)\n\(error.localizedDescription)")
                errorDetails = ErrorDetails(
                    name: "Account error",
                    message: error.localizedDescription
                )
                return
            }
            guard let authResult = authResult else {
                print("Error in \(#function): failed to get auth data result from create user")
                return
            }
            guard let firebaseUser = user else {
                print("Error in \(#function): user struct is nil")
                return
            }
            
            let userRef = self.firestore.collection("users").document(authResult.user.uid)
            do {
                try userRef.setData(from: firebaseUser)
            } catch {
                print("Error in \(#function)\n\(error)")
                errorDetails = ErrorDetails(
                    name: "Account error",
                    message: error.localizedDescription
                )
                return
            }

            self.currentUser = authResult.user
            self.signedIn = true
        }
    }
}
