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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .journal:
                    Text("journal")
                case .home:
                    Text("home")
                case .add:
                    AddView()
                case .calendar:
                    Text("calendar")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
