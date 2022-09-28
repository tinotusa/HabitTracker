//
//  HabitRowView.swift
//  Habit Tracker
//
//  Created by Tino on 10/6/2022.
//

import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    if habit.habitState == .quitting {
                        Text("Quitting")
                            .foregroundColor(.quittingColour)
                    } else {
                        Text("Forming")
                            .foregroundColor(.startingColour)
                    }
                    Spacer()
                    // TODO: Change to last updated
                    Text("Created: \(habit.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .fontWeight(.light)
                        .foregroundColor(.textColour)
                }
                .captionStyle()
                
                Text(habit.name)
                    .title2Style()
                    .foregroundColor(.primaryColour)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            Spacer()
            NavigationArrowIndicator()
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
