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
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            Text("\(habit.name) calendar")
            Button("Today") {
                date = Date()
            }
            HStack {
                Button {
                    moveMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text("\(month), \(String(year))")
                Spacer()
                Button {
                    moveMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                    if symbol != "Sat" {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            Divider()
            LazyVGrid(columns: columns) {
                ForEach(monthDates) { date in
                    if date.day != -1 {
                        Text("\(date.day)")
                            .background(viewModel.journalHasEntry(for: date.date) ? .green : .clear)
                            .onTapGesture {
                                Task {
                                    await viewModel.getJournalEntries(for: date.date)
                                }
                            }
                    } else  {
                        Spacer()
                    }
                }
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
        .onAppear {
            viewModel.setUp(userSession: userSession, habit: habit)
            Task {
                await viewModel.getJournalEntries()
            }
        }
        .fullScreenCover(isPresented: $showAddJournalEntryView) {
            JournalEntryView(habit: habit)
        }
    }

    var monthDates: [DateValue] {
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        var days: [DateValue] = range.compactMap { day -> DateValue in
            let date = calendar.date(byAdding: .day, value: day == 1 ? 0 : day - 1, to: startDate)!
            return DateValue(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        for _ in 0 ..< firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
    
    var month: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .autoupdatingCurrent
        let components = calendar.dateComponents([.month], from: date)
        guard let month = components.month else { return "Error" }
        return calendar.monthSymbols[month - 1]
    }
    
    var weekdaySymbols: [String] {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.weekdaySymbols
    }
    
    var year: Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .autoupdatingCurrent
        
        let components = calendar.dateComponents([.year], from: date)
        guard let year = components.year else { return 0 }
        return year
    }
    
    func moveMonth(by amount: Int) {
        date = Calendar.current.date(byAdding: .month, value: amount, to: date) ?? Date()
    }
}

struct HabitCalendar_Previews: PreviewProvider {
    static var previews: some View {
        HabitCalendar(habit: Habit.example)
            .environmentObject(UserSession())
    }
}
