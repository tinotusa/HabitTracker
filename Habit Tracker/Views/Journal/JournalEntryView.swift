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
                    VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
                        Text("How are you feeling?")
                        TextEditor(text: $viewModel.entry)
                            .frame(minHeight: Constants.minTextEditorHeight)
                            .whiteBoxTextFieldStyle()
                            .onChange(of: viewModel.entry) { entry in
                                viewModel.checkEntryLength(entry: entry)
                            }
                    }
                    .highlightCard()
                    
                    activitiesList
                    
                    VStack(spacing: Constants.vstackSpacing) {
                        Text("Rate how you feel")
                        RatingView(rating: $viewModel.rating)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .highlightCard()
                    
                    LongButton(text: "Add entry", isDisabled: !viewModel.allFieldsFilled) {
                        viewModel.addEntry(userSession: userSession, habit: habit)
                    }
                }
            }
        }
        .padding()
        .title2Style()
        .foregroundColor(.textColour)
        .onAppear {
            viewModel.activities = habit.activities.map { activity in
                Activity(name: activity.name, isCompleted: false)
            }
        }
        .backgroundView()
        .actionNotification(
            text: "Added new journal entry.",
            icon: "checkmark.circle.fill",
            showingNotifiction: $viewModel.showActionNotification,
            canTapToHide: true
        )
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
