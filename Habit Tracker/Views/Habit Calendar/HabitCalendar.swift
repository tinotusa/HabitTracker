//
//  HabitCalendar.swift
//  Habit Tracker
//
//  Created by Tino on 29/5/2022.
//

import SwiftUI

struct HabitCalendar: View {
    let habit: Habit
    
    @EnvironmentObject var userSession: UserSession
    @State private var date = Date()
    @State private var showAddJournalEntryView = false
    @StateObject var viewModel = HabitCalendarViewModel()
    
    var body: some View {
        VStack {
            Text("\(habit.name) calendar")
            Button("Today") {
                date = Date()
            }
            BaseCalendarView(date: $date) { currentDate in
                Task {
                    await viewModel.getJournalEntries(for: currentDate)
                }
            } isDateHighlighted: { currentDate in
                viewModel.journalHasEntry(for: currentDate)
            }
            
            Button("Add journal entry") {
                showAddJournalEntryView = true
            }
            
            Text("Entries")
            ScrollView(showsIndicators: false) {
                ForEach(viewModel.entriesForSelectedDate) { entry in
                    Text(entry.entry)
                }
            }
        }
        .onChange(of: date) { date in
            Task {
                await viewModel.getJournalEntries(inMonthOf: date)
            }
        }
        .task {
            if !userSession.isSignedIn {
                return
            }
            viewModel.setUp(userSession: userSession, habit: habit)
            await viewModel.getJournalEntries(inMonthOf: date)
        }
        .fullScreenCover(isPresented: $showAddJournalEntryView) {
            Task {
                await viewModel.getJournalEntries(inMonthOf: date)
            }
        } content: {
            JournalEntryView(habit: habit)
        }
    }
}

struct HabitCalendar_Previews: PreviewProvider {
    static var previews: some View {
        HabitCalendar(habit: Habit.example)
            .environmentObject(UserSession())
    }
}
