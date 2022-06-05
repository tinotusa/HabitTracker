//
//  EditHabitView.swift
//  Habit Tracker
//
//  Created by Tino on 4/6/2022.
//

import SwiftUI

struct EditHabitView: View {
    private let originalHabit: Habit
    
    @State private var habit: Habit
    @State private var userHasMadeChanges = false
    
    @StateObject var viewModel = EditHabitViewViewModel()
    
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    
    
    init(habit: Habit) {
        originalHabit = habit
        _habit = State(wrappedValue: habit)
    }
 
    var body: some View {
        NavigationView {
            VStack {
                Group {
                    Text("Edit habit view")
                    TextField("Habit name", text: $habit.name, prompt: Text("Habit name"))
                    Toggle("Quitting", isOn: $habit.isQuittingHabit)
                    Toggle("Starting", isOn: $habit.isStartingHabit)
                    DatePicker("Occurance time", selection: $habit.occurrenceTime, displayedComponents: [.hourAndMinute])
                }
                DayPickerView(selection: $habit.occurrenceDays)
                Stepper("Habit duration hours \(habit.durationHours)", value: $habit.durationHours, in: 0 ... 24)
                Stepper("Habit duration minutes \(habit.durationMinutes)", value: $habit.durationMinutes, in: 0 ... 60)
                Text("Activities")
                // TODO: This is a problem (after 1 character the field loses focus)
                ForEach($habit.activities) { $activity in
                    TextField("Activity", text: $activity.name, prompt: Text("Placeholder"))
                }
                Text("Reason for quitting / starting habit")
                TextEditor(text: $habit.reason)
                    .frame(maxHeight: 150)
                    .border(.gray)
                Button("Save changes") {
                    saveChanges()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        if habit != originalHabit && !viewModel.hasSavedSuccessfully {
                            userHasMadeChanges = true
                            return
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
        .confirmationDialog("Save", isPresented: $userHasMadeChanges) {
            Button(role: .destructive) {
                dismiss()
            } label: {
                Text("Discard changes")
            }

            Button(role: .cancel) {

            } label: {
                Text("Cancel")
            }
        } message: {
            Text("There're changes that have not been saved.")
        }
        .alert(
            viewModel.errorDetails?.name ?? "Error saving changes",
            isPresented: $viewModel.didError,
            presenting: viewModel.errorDetails
        ) { _ in
            Button(role: .cancel) {
                // nothing
            } label: {
                Text("Cancel")
            }
        } message: { details in
            Text(details.message)
        }
    }
}

extension EditHabitView {
    func saveChanges() {
        Task {
            await viewModel.saveHabit(habit, userSession: userSession)
        }
    }
}

struct EditHabitView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditHabitView(habit: Habit.example)
                .environmentObject(UserSession())
        }
    }
}
