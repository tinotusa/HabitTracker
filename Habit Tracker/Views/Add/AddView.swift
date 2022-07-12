//
//  AddView.swift
//  Habit Tracker
//
//  Created by Tino on 23/5/2022.
//

import SwiftUI
import Combine

struct AddView: View {
    @StateObject var viewModel = AddViewViewModel()
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        VStack(alignment: .leading) {
            header
                .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
                    Group {
                        Toggle("Quitting a habit", isOn: $viewModel.isQuittingHabit.animation())
                        Toggle("Starting a habit", isOn: $viewModel.isStartingHabit.animation())
                    }
                    
                    Divider()
                    
                    nameInput
                    
                    timeInput
                    
                    dayInput
                    
                    durationInput
                    
                    activityInput
                    
                    reasonInput
                    
                    Group {
                        createHabitButton
                        Spacer(minLength: 60) //TODO: Look for better solution (hardcoding seems wrong)
                    }
                }
                .padding()
            }
            .title2Style()
        }
        .backgroundView()
        .disabled(viewModel.isLoading)
        .actionNotification(
            text: "Adding habit.",
            showingNotifiction: $viewModel.showActionNotification,
            showProgressCircle: true,
            canTapToHide: false,
            willDisappearWhenFalse: $viewModel.isLoading
        )
        .actionNotification(
            text: "Added new habit.",
            icon: "checkmark.circle.fill",
            showingNotifiction: $viewModel.showActionNotification,
            canTapToHide: true
        )
        .alert(
            "Please allow notifications",
            isPresented: $viewModel.showSettingsForPermissions,
            presenting: viewModel.permissionsDetails
        ) { details in
            Button(role: .cancel) {
                // Default close
            } label: {
                Text("Deny")
            }
            Button("Accept") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        } message: { details in
            Text(details.message)
        }
        
    }
}

// MARK: - Subviews
private extension AddView {
    var header: some View {
        HStack {
            Text("Add habit")
                .titleStyle()
            Spacer()
            Button {
                Task {
                    await viewModel.addHabit(session: userSession)
                }
            } label: {
                Image(systemName: "plus")
                    .title2Style()
            }
            .disabled(!viewModel.allFieldsFilled)
        }
    }
    
    var nameInput: some View {
        TextField("Name", text: $viewModel.habitName, prompt: Text(viewModel.habitNamePrompt))
            .onChange(of: viewModel.habitName) { name in
                viewModel.checkNameLength(name: name)
            }
            .whiteBoxTextFieldStyle()
            .inputFieldHeader(title: "Habit name", helpText: .name)
            .highlightCard()
    }
    
    @ViewBuilder
    var timeInput: some View {
        DatePicker("Time", selection: $viewModel.occurrenceTime, displayedComponents: [.hourAndMinute])
            .labelsHidden()
        .frame(maxWidth: .infinity, alignment: .leading)
        .inputFieldHeader(title: "When do you usually do this?", helpText: .occurrenceTime)
        .highlightCard()
    }
    
    var dayInput: some View {
        DayPickerView(selection: $viewModel.occurrenceDays)
        .inputFieldHeader(title: "What days do you usually this?", helpText: .ooccurrenceDays)
        .highlightCard()
    }
    
    var durationInput: some View {
        Group {
            HStack {
                Text("Hours:")
                Spacer()
                CustomStepper(value: $viewModel.durationHours, minValue: 0, maxValue: 24)
            }
            HStack {
                Text("Minutes:")
                Spacer()
                CustomStepper(value: $viewModel.durationMinutes, minValue: 0, maxValue: 60)
            }
        }
        .inputFieldHeader(title: "How long does this usually last?", helpText: .duration)
        .highlightCard()
    }
    
    @ViewBuilder
    var activityInput: some View {
        if viewModel.isQuittingHabit {
            VStack(alignment: .leading, spacing: Constants.habitRowVstackSpacing) {
                TextField("Activity", text: $viewModel.activityInput, prompt: Text(viewModel.activityInputPrompt))
                    .submitLabel(.return)
                    .onSubmit {
                        viewModel.addActivity()
                    }
                    .onChange(of: viewModel.activityInput) { activityInput in
                        viewModel.checkActivityInputLength(activity: activityInput)
                    }
                    .whiteBoxTextFieldStyle()
                ForEach(viewModel.activities) { activity in
                    HStack {
                        Text(activity.name)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .whiteBoxTextFieldStyle()
                        Spacer()
                        ActivityDeleteButton {
                            withAnimation {
                                viewModel.removeActivity(activity: activity)
                            }
                        }
                    }
                }
                LongButton(text: "Add", isDisabled: viewModel.activityInput.isEmpty) {
                    viewModel.addActivity()
                }
            }
            .inputFieldHeader(title: "What do you want to do instead?", helpText: .activities)
            .highlightCard()
        }
    }
    
    var reasonInput: some View {
        TextEditor(text: $viewModel.reason)
            .frame(
                minHeight: Constants.minTextEditorHeight,
                maxHeight: Constants.maxTextEditorHeight
            )
            .whiteBoxTextFieldStyle()
            .onChange(of: viewModel.reason) { reason in
                viewModel.checkReasonInputLength(reason: reason)
            }
            .inputFieldHeader(title: "Why do you want to do this?", helpText: .reason)
            .highlightCard()
    }
    
    var createHabitButton: some View {
        LongButton(text: "Create habit", isDisabled: !viewModel.allFieldsFilled) {
            Task {
                await viewModel.addHabit(session: userSession)
            }
        }
    }
    
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
            .environmentObject(UserSession())
    }
}
