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
    
    var body: some View {
        VStack {
            Text(date.longDate)
            if viewModel.hasEntries {
                ForEach(viewModel.journalEntries) { entry in
                    Text(entry.entry)
                    RatingView(rating: .constant(entry.rating))
                }
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
