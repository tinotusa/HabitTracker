//
//  Habit_TrackerApp.swift
//  Habit Tracker
//
//  Created by Tino on 16/4/2022.
//

import SwiftUI
import Firebase
import FirebaseFunctions
import FirebaseAuth

@main
struct Habit_TrackerApp: App {
    @StateObject var userSession = UserSession()
    
    init() {
        FirebaseApp.configure()
        #if EMULATORS
        print("******* RUNNING ON EMULATORS *******")
        Functions.functions(region: "australia-southeast1").useEmulator(withHost: "localhost", port: 5001)
        Auth.auth().useEmulator(withHost: "localhost", port: 9099)

        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isPersistenceEnabled = false
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        #elseif DEBUG
        print("******* RUNNING ON LIVE FIREBASE *******")
        #endif
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
