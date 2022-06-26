//
//  EditHabitView.swift
//  Habit Tracker
//
//  Created by Tino on 4/6/2022.
//

import SwiftUI

struct EditHabitView: View {
    private let originalHabit: Habit
    
    @State private var userHasMadeChanges = false
    
    @StateObject var viewModel: EditHabitViewViewModel
    
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    
    
    init(habit: Habit) {
        originalHabit = habit
        _viewModel = StateObject(wrappedValue: EditHabitViewViewModel(habit: habit))
    }
    
    var header: some View {
        HStack {
            Button {
                if viewModel.habit != originalHabit && !viewModel.hasSavedSuccessfully {
                    userHasMadeChanges = true
                    return
                }
                dismiss()
            } label: {
                Label("Close", systemImage: "xmark")
            }
            
            Spacer()
            
            Button {
                saveChanges()
            } label: {
                Label("Save", systemImage: "square.and.arrow.down.fill")
            }
        }
        .title2Style()
        .foregroundColor(.textColour)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                VStack(alignment: .leading) {
                    header
                        .padding()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
                            VStack(alignment: .leading) {
                                Text("Habit name:")
                                TextField("Habit name", text: $viewModel.name, prompt: Text("Habit name"))
                                    .whiteBoxTextFieldStyle()
                            }
                            .highlightCard()
                            
                            VStack {
                                Toggle("Quitting", isOn: $viewModel.isQuitting.animation())
                                    .onChange(of: viewModel.isQuitting) { isQuitting in
                                        if isQuitting {
                                            withAnimation {
                                                viewModel.isStarting = false
                                            }
                                        }
                                    }
                                Toggle("Starting", isOn: $viewModel.isStarting.animation())
                                    .onChange(of: viewModel.isStarting) { isStarting in
                                        if isStarting {
                                            withAnimation {
                                                viewModel.isQuitting = false
                                            }
                                        }
                                    }
                            }
                            .highlightCard()
                            
                            VStack(alignment: .leading) {
                                Text("At what time do you want to do this?")
                                DatePicker("", selection: $viewModel.occurrenceTime, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .highlightCard()
                            
                            VStack(alignment: .leading) {
                                Text("On what days do you do this?")
                                DayPickerView(selection: $viewModel.occurrenceDays)
                            }
                            .highlightCard()
                            
                            VStack(alignment: .leading) {
                                Text("How long does it take?")
                                Stepper("Hours: \(viewModel.durationHours)", value: $viewModel.durationHours, in: 0 ... 24)
                                Stepper("Minutes: \(viewModel.durationMinutes)", value: $viewModel.durationMinutes, in: 0 ... 60)
                            }
                            .highlightCard()
                            if viewModel.isQuitting {
                                VStack(alignment: .leading, spacing: Constants.habitRowVstackSpacing) {
                                    Text("Activities")
                                    TextField("Activity", text: $viewModel.activityInput, prompt: Text(viewModel.activityInputPrompt))
                                        .whiteBoxTextFieldStyle()
                                    
                                    ForEach($viewModel.activities) { $activity in
                                        HStack {
                                            TextField("Activity", text: $activity.name, prompt: Text("Activity placeholder"))
                                                .lineLimit(1)
                                                .whiteBoxTextFieldStyle()
                                            Spacer()
                                            ActivityDeleteButton() {
                                                withAnimation {
                                                    viewModel.removeActivity(activity)
                                                }
                                            }
                                        }
                                    }
                                    LongButton(text: "Add activity") {
                                        withAnimation {
                                            viewModel.addActivity()
                                        }
                                    }
                                }
                                .highlightCard()
                            }
                            
                            
                            VStack(alignment: .leading) {
                                Text(viewModel.reasonText)
                                TextEditor(text: $viewModel.reason)
                                    .frame(minHeight: Constants.textEditorHeight)
                                    .whiteBoxTextFieldStyle()
                            }
                            .highlightCard()
                            
                            LongButton(text: "Save changes") {
                                saveChanges()
                            }
                        }
                        .padding()
                    }
                }
                .title2Style()
            }
            .navigationBarHidden(true)
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
        .onAppear {
            if !userSession.isSignedIn { return }
            viewModel.userSession = userSession
        }
    }
}

extension EditHabitView {
    func saveChanges() {
        Task {
            await viewModel.saveHabit()
        }
    }
}

struct EditHabitView_Previews: PreviewProvider {
    static var previews: some View {
        EditHabitView(habit: Habit.example)
            .environmentObject(UserSession())
    }
}
