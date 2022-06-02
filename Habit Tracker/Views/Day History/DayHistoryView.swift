//
//  DayHistoryView.swift
//  Habit Tracker
//
//  Created by Tino on 1/6/2022.
//

import SwiftUI

struct DayHistoryView: View {
    let date: Date
    @EnvironmentObject var userSession: UserSession
    @StateObject var viewModel = DayHistoryViewViewModel()
    @State private var selectedEntry: JournalEntry?
    
    var body: some View {
        VStack {
            Text(date.longDate)
            if viewModel.hasEntries {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.journalEntries) { entry in
                            VStack {// TODO: Change to habit name
                                Text(entry.entry)
                                RatingView(rating: .constant(entry.rating))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedEntry = entry
                            }
                        }
                    }
                }
                if let selectedEntry = selectedEntry {
                    Text("On this day you wrote:")
                    TextEditor(text: .constant(selectedEntry.entry))
                        .frame(maxHeight: 150)
                        .border(.black)
                    Text("You did this:")
                    ForEach(selectedEntry.activities) { activity in
                        if activity.isCompleted {
                            Text(activity.name)
                        }
                    }
                    Text("instead of:")
                    Text("Habit name here")
                    Text("Rating of the day")
                    RatingView(rating: .constant(selectedEntry.rating))
                } else {
                    Text("Select an entry to view")
                }
                Spacer()
            } else {
                Text("No entries for this day")
            }
            
        }
        .task {
            await viewModel.getHabits(for: date)
        }
    }
}

struct DayHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DayHistoryView(date: Date())
            .environmentObject(UserSession())
    }
}
