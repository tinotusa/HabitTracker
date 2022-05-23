//
//  HomeView.swift
//  Habit Tracker
//
//  Created by Tino on 23/5/2022.
//

import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    var id: Self { self }
    case journal = "Journal"
    case home = "Home"
    case add = "Add"
    case calendar = "Calendar"
    
    
    var imageName: String {
        switch self {
        case .journal: return "book"
        case .home: return "house"
        case .add: return "plus"
        case .calendar: return "calendar"
        }
    }
}

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
