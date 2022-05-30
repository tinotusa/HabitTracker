//
//  JournalEntryView.swift
//  Habit Tracker
//
//  Created by Tino on 30/5/2022.
//

import SwiftUI

struct JournalEntryView: View {
    let habit: Habit
    @StateObject var viewModel = JournalEntryViewViewModel()
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Button("Close") {
                dismiss()
            }
            Text("Journal entry")
            Text("How do are you feeling?")
            TextEditor(text: $viewModel.entry)
                .frame(height: 160)
                .border(.gray)
            Text("Which of these things did you do?")
            ForEach($viewModel.activities) { $activity in
                HStack {
                    Text(activity.name)
                    Toggle("activity", isOn: $activity.isCompleted)
                        .labelsHidden()
                }
            }
            Text("How do you feel?")
            RatingView(rating: $viewModel.rating)
            Button("Add Entry") {
                viewModel.addEntry(userSession: userSession, habit: habit)
            }
        }
        .onAppear {
            viewModel.activities = habit.activities.map { activity in
                JournalEntry.Activity(name: activity, isCompleted: false)
            }
        }
    }
}

struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryView(habit: .example)
            .environmentObject(UserSession())
    }
}
