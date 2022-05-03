//
//  ContentView.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        if userSession.signedIn {
            VStack {
                Text("Logged in as \(userSession.currentUser?.email ?? "no email")")
                Button("Logout") {
                    userSession.signOut()
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSession())
    }
}
