//
//  Habit_TrackerApp.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import SwiftUI
import Firebase

@main
struct Habit_TrackerApp: App {
    @StateObject var userSession = UserSession()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userSession.isSignedIn {
                    MainView()
                        .environmentObject(userSession)
                } else {
                    LoginView()
                        .environmentObject(userSession)
                }
            }
        }
        
    }
}
