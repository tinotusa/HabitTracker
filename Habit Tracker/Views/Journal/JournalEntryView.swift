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
        VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
                    Text("Journal entry for: \(habit.name)")
                    Text("How are you feeling?")
                    TextEditor(text: $viewModel.entry)
                        .frame(minHeight: Constants.textEditorHeight)
                        .whiteBoxTextFieldStyle()
                    
                    activitiesList
                    
                    VStack(spacing: Constants.vstackSpacing) {
                        Text("Rate how you feel")
                        RatingView(rating: $viewModel.rating)
                        LongButton(text: "Add entry") {
                            viewModel.addEntry(userSession: userSession, habit: habit)
                        }
                    }
                }
            }
        }
        .padding()
        .title2Style()
        .foregroundColor(.textColour)
        .onAppear {
            viewModel.activities = habit.activities.map { activity in
                JournalEntry.Activity(name: activity.name, isCompleted: false)
            }
        }
        .backgroundView()
    }
}

private extension JournalEntryView {
    var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("Close", systemImage: "xmark")
                
            }
        }
        .title2Style()
    }
    
    @ViewBuilder
    var activitiesList: some View {
        if habit.isQuittingHabit {
            VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
                Text("Which of these activities did you do instead?")
                ForEach($viewModel.activities) { $activity in
                    Toggle(activity.name, isOn: $activity.isCompleted)
                        .title2Style()
                }
            }
            .highlightCard()
        }
    }
    
}
struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryView(habit: .example)
            .environmentObject(UserSession())
    }
}
