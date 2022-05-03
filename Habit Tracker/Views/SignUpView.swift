//
//  SignUpView.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var emailConfirmation = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var birthday = Date()
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var user: FirebaseUser?
    
    var body: some View {
        VStack {
            Text("Sign up view")
            Group {
                TextField("First name", text: $firstName, prompt: Text("First name"))
                    .textContentType(.givenName)
                TextField("First name", text: $lastName, prompt: Text("Last name"))
                    .textContentType(.familyName)
            }
    
            Group {
                TextField("Email", text: $email, prompt: Text("Email"))
                    .textContentType(.emailAddress)
                TextField("Email", text: $emailConfirmation, prompt: Text("Email confirmation"))
                    .textContentType(.emailAddress)
            }
            
            Group {
                TextField("Password", text: $password, prompt: Text("Password"))
                    .textContentType(.password)
                TextField("Password", text: $passwordConfirmation, prompt: Text("Password confirmation"))
                    .textContentType(.password)
            }
            
            DatePicker("Birthday", selection: $birthday, in: ...Date(), displayedComponents: [.date])
            
            HStack {
                Button("Create Account") {
                    user = FirebaseUser(
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        birthday: birthday
                    )
                    userSession.createAccount(withEmail: email, password: password, user: user)
                }
                Button("Back") {
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .textFieldStyle(.roundedBorder)
        .padding()
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(UserSession())
    }
}
