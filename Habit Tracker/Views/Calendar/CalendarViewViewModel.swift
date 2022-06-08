//
//  CalendarViewViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 31/5/2022.
//

import Foundation

final class CalendarViewViewModel: ObservableObject {
    @Published var entriesForSelectedDate = [JournalEntry]()
    private var calendarService: CalendarServiceProtocol
    
    init(calendarService: CalendarServiceProtocol = CalendarService()) {
        self.calendarService = calendarService
    }
}

extension CalendarViewViewModel {
    func hasJournalEntry(for date: Date) -> Bool {
        for entry in entriesForSelectedDate {
            if entry.dateCreated.isEqual(to: date) {
                return true
            }
        }
        return false
    }
    
    @MainActor
    func getHabitsForMonth(date: Date) async {
        entriesForSelectedDate = await calendarService.getHabitsForMonth(date: date)
    }
}
