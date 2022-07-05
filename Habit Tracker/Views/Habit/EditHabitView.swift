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
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
                        nameInput
                        
                        habitStatus
                        
                        timeInput
                        
                        dayInput
                        
                        durationInput
                        
                        activitiesInput
                        
                        reasonInput
                        
                        LongButton(text: "Save changes") {
                            saveChanges()
                        }
                    }
                    .padding()
                }
            }
            .title2Style()
            .foregroundColor(.textColour)
            .backgroundView()
            .navigationBarHidden(true)
            .confirmationDialog("Save", isPresented: $userHasMadeChanges) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("Discard changes")
                }
            } message: {
                Text("There're changes that have not been saved.")
            }
            .alert(
                viewModel.errorDetails?.name ?? "Error saving changes",
                isPresented: $viewModel.didError,
                presenting: viewModel.errorDetails
            ) { _ in
                // Default cancel button
            } message: { details in
                Text(details.message)
            }
        }
        .onAppear {
            if !userSession.isSignedIn { return }
            viewModel.userSession = userSession
        }
        .actionNotification(
            text: "Saving changes.",
            showingNotifiction: $viewModel.showActionNotification,
            showProgressCircle: true,
            canTapToHide: false,
            willDisappearWhenFalse: $viewModel.isLoading
        )
        .actionNotification(
            text: "Saved changes.",
            icon: "checkmark.circle.fill",
            showingNotifiction: $viewModel.showActionNotification
        )
    }
}
// MARK: - Subviews
private extension EditHabitView {
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
        .padding()
    }
    
    var nameInput: some View {
        VStack(alignment: .leading) {
            Text("Habit name:")
            TextField("Habit name", text: $viewModel.name, prompt: Text("Habit name"))
                .whiteBoxTextFieldStyle()
                .onChange(of: viewModel.name) { name in
                    viewModel.checkNameLength(name: name)
                }
        }
        .highlightCard()
    }
    
    var habitStatus: some View {
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
    }
    
    var timeInput: some View {
        VStack(alignment: .leading) {
            Text("At what time do you want to do this?")
            DatePicker("", selection: $viewModel.occurrenceTime, displayedComponents: [.hourAndMinute])
                .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .highlightCard()
    }
    
    var dayInput: some View {
        VStack(alignment: .leading) {
            Text("On what days do you do this?")
            DayPickerView(selection: $viewModel.occurrenceDays)
        }
        .highlightCard()
    }
    
    var durationInput: some View {
        VStack(alignment: .leading) {
            Text("How long does it take?")
            HStack {
                Text("Hours")
                Spacer()
                CustomStepper(value: $viewModel.durationHours, minValue: 0, maxValue: 24)
            }
            HStack {
                Text("Minutes")
                Spacer()
                CustomStepper(value: $viewModel.durationMinutes, minValue: 0, maxValue: 60)
            }
        }
        .highlightCard()
    }
    
    @ViewBuilder
    var activitiesInput: some View {
        if viewModel.isQuitting {
            VStack(alignment: .leading, spacing: Constants.habitRowVstackSpacing) {
                Text("Activities")
                TextField("Activity", text: $viewModel.activityInput, prompt: Text(viewModel.activityInputPrompt))
                    .whiteBoxTextFieldStyle()
                    .onChange(of: viewModel.activityInput) { activity in
                        viewModel.checkActivityInputLength(activity: activity)
                    }
                
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
                LongButton(text: "Add activity", isDisabled: viewModel.activityInput.isEmpty) {
                    withAnimation {
                        viewModel.addActivity()
                    }
                }
            }
            .highlightCard()
        }
    }
    
    var reasonInput: some View {
        VStack(alignment: .leading) {
            Text(viewModel.reasonTextPrompt)
            TextEditor(text: $viewModel.reason)
                .frame(minHeight: Constants.minTextEditorHeight)
                .whiteBoxTextFieldStyle()
                .onChange(of: viewModel.reason) { reason in
                    viewModel.checkReasonInputLength(reason: reason)
                }
        }
        .highlightCard()
    }
    
}

// MARK: - Functions
private extension EditHabitView {
    func saveChanges() {
        Task {
            await viewModel.saveHabit()
        }
    }
}

// MARK: - Previews
struct EditHabitView_Previews: PreviewProvider {
    static var previews: some View {
        EditHabitView(habit: Habit.example)
            .environmentObject(UserSession())
    }
}
