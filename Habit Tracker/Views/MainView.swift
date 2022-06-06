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
        NavigationView {
            ZStack(alignment: .bottom) {
                NavigationLink(destination: JournalEntryView(habit: notificationManager.currentHabit ?? Habit.example), isActive: $notificationManager.navigationBindingActive) {
                    EmptyView()
                }
                Group {
                    switch selectedTab {
                    case .journal:
                        Text("journal")
                    case .home:
                        HomeView()
                    case .add:
                        AddView()
                    case .calendar:
                        CalendarView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarHidden(true)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(NotificationManager())
    }
}
