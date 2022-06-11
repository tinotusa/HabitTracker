//
//  MainView.swift
//  Habit Tracker
//
//  Created by Tino on 23/5/2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("journal")
                .tag(Tab.journal)
                .tabItem {
                    Label(Tab.journal.rawValue, systemImage: Tab.journal.imageName)
                }
            HomeView()
                .tag(Tab.home)
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.imageName)
                }
            AddView()
                .tag(Tab.add)
                .tabItem {
                    Label(Tab.add.rawValue, systemImage: Tab.add.imageName)
                }
            
            CalendarView()
                .tag(Tab.calendar)
                .tabItem {
                    Label(Tab.calendar.rawValue, systemImage: Tab.calendar.imageName)
                }
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(NotificationManager())
    }
}
