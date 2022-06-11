//
//  HabitRowView.swift
//  Habit Tracker
//
//  Created by Tino on 10/6/2022.
//

import SwiftUI

struct RightArrow: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .title2Style()
            .padding(.horizontal)
    }
}

struct HabitRowView: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Group {
                    if habit.isQuittingHabit {
                        Text("Quitting")
                            .foregroundColor(.quittingColour)
                    } else {
                        Text("Forming")
                            .foregroundColor(.startingColour)
                    }
                }
                .captionStyle()
                
                HStack(alignment: .lastTextBaseline) {
                    Text(habit.name)
                        .title2Style()
                        .foregroundColor(.primaryColour)
                    Spacer()
//                    Text("Created: \(habit.createdAt.formatted(date: .abbreviated, time: .omitted))")
//                        .font(.subheadline)
//                        .foregroundColor(.textColour)
                }
            }
            Spacer()
            RightArrow()
        }
        .padding()
        .background(Color.highlightColour)
        .cornerRadius(Constants.cornerRadius)
        .shadow(
            color: .shadow.opacity(Constants.shadowOpacity),
            radius: Constants.shadowRadius,
            x: 0,
            y: 5
        )
    }
}

struct HabitRowView_Previews: PreviewProvider {
    static var previews: some View {
        HabitRowView(habit: .example)
    }
}
