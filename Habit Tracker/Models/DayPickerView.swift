//
//  DayTimePickerView.swift
//  Habit Tracker
//
//  Created by Tino on 24/5/2022.
//

import SwiftUI

struct DayPickerView: View {
    @Binding var selection: Set<Day>
    @State private var selectedDays = Array(repeating: false, count: 7)
    @State private var hours = 1
    @State private var minutes = 0
    @State private var showingPicker = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Days:")
                Text(namesOfDaysSelected)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(showingPicker ? 180 : 0))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    showingPicker.toggle()
                }
            }
            if showingPicker {
                VStack {
                    ForEach(Day.allCases) { day in
                        HStack {
                            Text(day.fullName)
                            Spacer()
                            if selectedDays[day.rawValue] {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDays[day.rawValue].toggle()
                            if selectedDays[day.rawValue] {
                                selection.insert(day)
                            } else {
                                selection.remove(day)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    var namesOfDaysSelected: String {
        if selection.isEmpty {
            return "No days selected"
        }
        if selection.count == 2 && selection.allSatisfy({ $0.isWeekend }) {
            return "Every weekend"
        }
        if selection.count == 5 && selection.allSatisfy( { $0.isWeekday }) {
            return "Every weekday"
        }
        if selection.count == 7 {
            return "Everyday"
        }
        let names = selection.sorted().map {
            $0.shortName
        }
        return ListFormatter.localizedString(byJoining: names)
    }
}

struct DayPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DayPickerView(
            selection: .constant([.monday])
        )
    }
}
