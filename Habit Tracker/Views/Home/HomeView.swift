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
    
    var body: some View {
        VStack {
            Text("home")
            Button("Logout") {
                userSession.signOut()
                print("logged out")
            }
            ForEach(viewModel.habits) { habit in
                VStack {
                    Text(habit.isQuittingHabit ? "Quiting" : "Forming")
                        .foregroundColor(habit.isQuittingHabit ? .red : .green)
                    Text(habit.name)
                }
            }
            HStack {
                Button("prev") {
                    Task {
                        await viewModel.getPreviousHabits(userSession: userSession)
                    }
                }
                .disabled(!viewModel.hasPreviousPage)
//                
                Button("Next") {
                    Task {
                        await viewModel.getNextHabits(userSession: userSession)
                    }
                }
                .disabled(!viewModel.hasNextPage)
            }
        
        }
        .onAppear {
            Task {
                if userSession.isSignedIn {
                    await viewModel.getHabits(userSession: userSession)
                }
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
