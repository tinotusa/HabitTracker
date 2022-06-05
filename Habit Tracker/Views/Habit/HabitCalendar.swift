//
//  HabitCalendar.swift
//  Habit Tracker
//
//  Created by Tino on 29/5/2022.
//

import SwiftUI

struct HabitCalendar: View {
    @State private var habit: Habit
    
    @EnvironmentObject var userSession: UserSession
    @State private var date = Date()
    @State private var showAddJournalEntryView = false
    @StateObject var viewModel = HabitCalendarViewModel()
    @State private var showEditingView = false
    @Environment(\.dismiss) var dismiss
    
    init(habit: Habit) {
        _habit = State(wrappedValue: habit)
    }
    
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
        .toolbar {
            ToolbarItemGroup {
                HStack {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.delete(habit: habit, userSession: userSession)
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    
                    Button("Edit") {
                        showEditingView = true
                    }
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
        .sheet(isPresented: $showEditingView) {
            EditHabitView(habit: habit)
                .onDisappear {
                    Task {
                        habit = await viewModel.getHabit(id: habit.id, userSession: userSession)
                    }
                }
        }
    }
}

struct HabitCalendar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HabitCalendar(habit: Habit.example)
                .environmentObject(UserSession())
        }
    }
}
