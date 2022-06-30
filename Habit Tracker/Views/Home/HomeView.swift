//
//  HomeView.swift
//  Habit Tracker
//
//  Created by Tino on 23/5/2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject var viewModel = HomeViewViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack(alignment: .lastTextBaseline) {
                    Text("Habits")
                        .titleStyle()
                    Spacer()
                    // TODO: Maybe put the edit button here (can edit user info)
                    Button("Logout") {
                        userSession.signOut()
                        print("logged out")
                    }
                    .captionStyle()
                    .foregroundColor(.textColour)
                }
                .padding(.horizontal)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Constants.habitRowVstackSpacing) {
                        ForEach(viewModel.habits) { habit in
                            NavigationLink(destination: HabitCalendar(habit: habit)) {
                                HabitRowView(habit: habit)
                            }
                        }
                        if viewModel.hasNextPage {
                            RowLoadingView()
                                .onAppear {
                                    Task {
                                        await viewModel.getNextHabits(userSession: userSession)
                                    }
                                }
                        }
                    }
                    .padding()
                }
                Spacer(minLength: 90) // TODO: Fix me
            }
            .backgroundView()
            .task {
                if userSession.isSignedIn {
                    await viewModel.getHabits(userSession: userSession)
                }
            }
            .overlay {
                NavigationLink(
                    destination: JournalEntryView(habit: notificationManager.currentHabit ?? Habit.example),
                    isActive: $notificationManager.navigationBindingActive
                ) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .navigationViewStyle(.stack)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserSession())
            .environmentObject(NotificationManager())
    }
}
