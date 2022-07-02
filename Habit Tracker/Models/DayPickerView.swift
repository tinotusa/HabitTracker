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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isSetEveryday = false
    @State private var isSetEveryWeekend = false
    @State private var isSetEveryWeekday = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Everyday", isOn: $isSetEveryday)
                .onChange(of: isSetEveryday) { isSet in
                    setEveryday(isSet: isSet)
                }
            Toggle("Every weekend", isOn: $isSetEveryWeekend)
                .onChange(of: isSetEveryWeekend) { isSet in
                    setEveryWeekend(isSet: isSet)
                }
            Toggle("Every weekday", isOn: $isSetEveryWeekday)
                .onChange(of: isSetEveryWeekday) { isSet in
                    setEveryWeekday(isSet: isSet)
                }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Day.allCases) { day in
                        Button {
                            if selection.contains(day) {
                                selection.remove(day)
                            } else {
                                selection.insert(day)
                            }
                        } label : {
                            Text("\(day.shortName)")
                                .padding()
                                .title2Style()
                                .frame(width: 100, height: 60)
                                .background(selection.contains(day) ? Color.primaryColour : Color.backgroundColour)
                                .foregroundColor(.backgroundColour)
                                .cornerRadius(Constants.cornerRadius)
                        }
                    }
                }
            }
            .onChange(of: selection) { selection in
                if selection.count == Day.allCases.count {
                    withAnimation {
                        isSetEveryday = true
                    }
                } else if selection.count == 5 && selection.allSatisfy({ day in
                    day.isWeekday
                }) {
                    withAnimation {
                        isSetEveryWeekday = true
                    }
                } else if selection.count == 2 && selection.allSatisfy({ day in
                    day.isWeekend
                }) {
                    withAnimation {
                        isSetEveryWeekend = true
                    }
                } else {
                    withAnimation {
                        isSetEveryWeekday = false
                        isSetEveryWeekend = false
                        isSetEveryday = false
                    }
                }
            }
        }
    }
}

private extension DayPickerView {
    func setEveryday(isSet: Bool) {
        if isSet {
            withAnimation {
                isSetEveryWeekday = false
                isSetEveryWeekend = false
            }
            selection = []
            Day.allCases.forEach { day in
                selection.insert(day)
            }
        }
    }
    
    func setEveryWeekend(isSet: Bool) {
        if isSet {
            withAnimation {
                isSetEveryday = false
                isSetEveryWeekday = false
            }
            selection = []
            Day.weekends.forEach { day in
                selection.insert(day)
            }
        }
    }
    
    func setEveryWeekday(isSet: Bool) {
        if isSet {
            withAnimation {
                isSetEveryday = false
                isSetEveryWeekend = false
            }
            selection = []
            Day.weekdays.forEach { day in
                selection.insert(day)
            }
        }
    }
    
}

struct DayPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DayPickerView(
            selection: .constant([.monday, .wednesday])
        )
    }
}
