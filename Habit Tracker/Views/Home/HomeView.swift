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
        Text("home")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserSession())
    }
}
