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
    @State private var selectedDate = Date()
    @State private var showAddJournalEntryView = false
    @StateObject var viewModel = HabitCalendarViewModel()
    @State private var showEditingView = false
    @Environment(\.dismiss) var dismiss
    
    init(habit: Habit) {
        _habit = State(wrappedValue: habit)
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Constants.habitRowVstackSpacing) {
                    HStack(alignment: .lastTextBaseline) {
                        Text("\(habit.name)")
                            .title2Style()
                            .lineLimit(1)
                    }
                    
                    BaseCalendarView(date: $date) { currentDate in
                        Task {
                            await viewModel.getJournalEntries(for: currentDate)
                            selectedDate = currentDate
                        }
                    } isDateHighlighted: { currentDate in
                        viewModel.journalHasEntry(for: currentDate)
                    }
                    
                    Text("Entries for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                        .title2Style()
                    
                    ForEach(viewModel.entriesForSelectedDate) { entry in
                        HStack {
                            Text(entry.entry)
                                .lineLimit(2)
                                .captionStyle()
                                .foregroundColor(.textColour)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Text(entry.dateCreated.formatted(date: .omitted, time: .shortened))
                        }
                        .highlightCard()
                    }
                }
                Spacer(minLength: 70) // TODO: Find better solution
            }
        }
        .disabled(viewModel.isLoading)
        .padding()
        .backgroundView()
        .actionNotification(
            text: "Deleing habit",
            showingNotifiction: $viewModel.showingActionNotification,
            canTapToHide: false,
            willDisappearWhenFalse: $viewModel.isLoading
        )
        .actionNotification(
            text: "Deleted habit.",
            icon: "checkmark.circle.fill",
            showingNotifiction: $viewModel.showingActionNotification,
            canTapToHide: false
        )
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
            await viewModel.getJournalEntries(for: date)
        }
        .fullScreenCover(isPresented: $showAddJournalEntryView) {
            Task {
                await viewModel.getJournalEntries(inMonthOf: date)
            }
        } content: {
            JournalEntryView(habit: habit)
        }
        .fullScreenCover(isPresented: $showEditingView) {
            EditHabitView(habit: habit)
                .onDisappear {
                    Task {
                        habit = await viewModel.getHabit(id: habit.id, userSession: userSession)
                    }
                }
        }
        .confirmationDialog(
            "Delete habit",
            isPresented: $viewModel.showingDeleteConfirmation
        ) {
            Button(role: .destructive) {
                Task {
                    await viewModel.delete(habit: habit, userSession: userSession)
                    dismiss()
                }
            } label: {
                Text("Delete")
            }
        } message: {
            Text("Are you sure you want to delete this habit?")
        }
        .navigationBarHidden(true)
        .navigationViewStyle(.stack)
    }
}

private extension HabitCalendar {    
    var header: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                HStack {
                    Label("Back", systemImage: "chevron.left")
                }
                .title2Style()
            }
            
            Spacer()
            
            Button {
                viewModel.showingDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .title2Style()
            }
            
            Button {
                showEditingView = true
            } label: {
                Text("Edit")
                    .title2Style()
            }
            
            Button {
                showAddJournalEntryView = true
            } label: {
                Text("Add")
                    .title2Style()
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
