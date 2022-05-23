//
//  HomeView.swift
//  Habit Tracker
//
//  Created by Tino on 23/5/2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        VStack {
            Text("home")
            Button("Logout") {
                userSession.signOut()
                print("logged out")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserSession())
    }
}
