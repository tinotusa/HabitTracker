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
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                BackgroundView()
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
                                
                                Button {
                                    viewModel.addEntry(userSession: userSession, habit: habit)
                                } label: {
                                    Text("Add entry")
                                        .longButtonStyle(proxy: proxy)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                }
                .padding()
            }
            .title2Style()
            .foregroundColor(.textColour)
            .onAppear {
                viewModel.activities = habit.activities.map { activity in
                    JournalEntry.Activity(name: activity.name, isCompleted: false)
                }
            }
        }
        //        VStack {
        //            Button("Close") {
        //                dismiss()
        //            }
        //            Text("Journal entry")
        //            Text("How do are you feeling?")
        //            TextEditor(text: $viewModel.entry)
        //                .frame(height: 160)
        //                .border(.gray)
        //            if habit.isQuittingHabit {
        //                Text("Which of these things did you do?")
        //                ForEach($viewModel.activities) { $activity in
        //                    HStack {
        //                        Text(activity.name)
        //                        Toggle("activity", isOn: $activity.isCompleted)
        //                            .labelsHidden()
        //                    }
        //                }
        //            }
        //            Text("How do you feel?")
        //            RatingView(rating: $viewModel.rating)
        //            Button("Add Entry") {
        //                viewModel.addEntry(userSession: userSession, habit: habit)
        //            }
        //        }
        //        .onAppear {
        //            viewModel.activities = habit.activities.map { activity in
        //                JournalEntry.Activity(name: activity.name, isCompleted: false)
        //            }
        //        }
    }
}

struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryView(habit: .example)
            .environmentObject(UserSession())
    }
}
