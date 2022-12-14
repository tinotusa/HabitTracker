//
//  CalendarView.swift
//  Habit Tracker
//
//  Created by Tino on 31/5/2022.
//

import SwiftUI

struct CalendarView: View {
    @State private var date = Date()
    @StateObject var viewModel = CalendarViewViewModel()
    @EnvironmentObject var userSession: UserSession
    @State private var selectedDate = Date()
    @State private var showingDayHistory = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
                NavigationLink(destination: DayHistoryView(date: selectedDate), isActive: $showingDayHistory) {
                    EmptyView()
                }
                Text("Calendar")
                    .titleStyle()
                BaseCalendarView(date: $date) { currentDate in
                    selectedDate = currentDate
                    self.showingDayHistory = true
                } isDateHighlighted: { date in
                    return viewModel.hasJournalEntry(for: date)
                }
                Spacer()
            }
            .padding()
            .backgroundView()
            .onChange(of: date) { _ in
                Task {
                    await viewModel.getHabitsForMonth(date: date)
                }
            }
            .task {
                if !userSession.isSignedIn {
                    return
                }
                await viewModel.getHabitsForMonth(date: date)
            }
            .navigationBarHidden(true)
            .navigationViewStyle(.stack)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(UserSession())
    }
}
