//
//  BaseCalendarView.swift
//  Habit Tracker
//
//  Created by Tino on 31/5/2022.
//

import SwiftUI

struct BaseCalendarView: View {
    @Binding var date: Date
    let dateTapFunction: ((Date) -> Void)?
    let isDateHighlighted: ((Date) -> Bool)?
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init(
        date: Binding<Date>,
        dateTapFunction: ((Date) -> Void)? = nil,
        isDateHighlighted: ((Date) -> Bool)? = nil
    ) {
        _date = date
        self.dateTapFunction = dateTapFunction
        self.isDateHighlighted = isDateHighlighted
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                previousMonthButton
                Spacer()
                Text("\(month), \(String(year))")
                    .title2Style()
                Spacer()
                nextMonthButton
            }
            
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                        .captionStyle()
                        .foregroundColor(.textColour)
                }
            }
            
            LazyVGrid(columns: columns) {
                ForEach(monthDates) { dateValue in
                    if dateValue.day != -1 {
                        dayView(dateValue: dateValue)
                    } else  {
                        Spacer()
                    }
                }
            }
        }
    }
}

private extension BaseCalendarView {
    @ViewBuilder
    func dayView(dateValue: DateValue) -> some View {
        Text("\(dateValue.day)")
            .padding(.vertical)
            .lineLimit(1)
            .captionStyle()
            .foregroundColor(.calendarTextColour)
            .frame(maxWidth: .infinity)
            .background(
                isDateHighlighted?(dateValue.date) ?? false ?
                Color.primaryColour :
                Color.calendarBackgroundColour
            )
            .cornerRadius(Constants.cornerRadius)
            .onTapGesture {
                dateTapFunction?(dateValue.date)
            }
    }
    
    var previousMonthButton: some View {
        Button {
            moveMonth(by: -1)
        } label: {
            Image(systemName: "chevron.left")
                .title2Style()
        }
    }
    
    var nextMonthButton: some View {
        Button {
            moveMonth(by: 1)
        } label: {
            Image(systemName: "chevron.right")
                .title2Style()
        }
    }
    
    var month: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date)
        guard let month = components.month else { return "Error" }
        return calendar.monthSymbols[month - 1]
    }
    
    var weekdaySymbols: [String] {
        return Calendar.current.shortWeekdaySymbols
    }
    
    var year: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        guard let year = components.year else { return 0 }
        return year
    }
    
    func moveMonth(by amount: Int) {
        withAnimation {
            date = Calendar.current.date(byAdding: .month, value: amount, to: date) ?? Date()
        }
    }
    
    var monthDates: [DateValue] {
        let calendar = Calendar.current
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
}

struct BaseCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        BaseCalendarView(
            date: .constant(Date())
        )
    }
}
