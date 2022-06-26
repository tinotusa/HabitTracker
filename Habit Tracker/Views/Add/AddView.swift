//
//  AddView.swift
//  Habit Tracker
//
//  Created by Tino on 23/5/2022.
//

import SwiftUI

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

private extension AddView {
    var header: some View {
        HStack {
            Text("Add habit")
                .titleStyle()
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "plus")
                    .title2Style()
            }
            .disabled(!viewModel.allFieldsFilled)
        }
    }
    
    var nameInput: some View {
        VStack(alignment: .leading) {
            Text("Habit name")
            TextField("Name", text: $viewModel.habitName, prompt: Text(viewModel.habitNamePrompt))
                .whiteBoxTextFieldStyle()
        }
        .highlightCard()
    }
    
    @ViewBuilder
    var timeInput: some View {
        if viewModel.isQuittingHabit {
            VStack(alignment: .leading) {
                Text("When do you usually do this?")
                DatePicker("Time", selection: $viewModel.occurrenceTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .highlightCard()
        }
    }
    
    var dayInput: some View {
        VStack(alignment: .leading) {
            Text("What days do you usually this?")
            DayPickerView(selection: $viewModel.occurrenceDays)
        }
        .highlightCard()
    }
    
    var durationInput: some View {
        VStack(alignment: .leading) {
            Text("What time do you usually this?")
            HStack {
                Text("Hrs:")
                Picker("Hours", selection: $viewModel.durationHours) {
                    ForEach(0 ..< 25) { hour in
                        if hour == 0 || hour > 1 {
                            Text("\(hour) hours")
                        } else {
                            Text("\(hour) hour")
                        }
                    }
                }
                Text("Mins:")
                Picker("Minutes", selection: $viewModel.durationMinutes) {
                    ForEach(0 ..< 61) { minute in
                        if minute == 0 || minute > 1 {
                            Text("\(minute) minutes")
                        } else {
                            Text("\(minute) minute")
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .highlightCard()
    }
    
    @ViewBuilder
    var activityInput: some View {
        if viewModel.isQuittingHabit {
            VStack(alignment: .leading, spacing: Constants.habitRowVstackSpacing) {
                Text("What do you want to do instead?")
                TextField("Activity", text: $viewModel.activityInput, prompt: Text(viewModel.activityInputPrompt))
                    .submitLabel(.return)
                    .onSubmit {
                        viewModel.addActivity()
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
                LongButton(text: "Add") {
                    viewModel.addActivity()
                }
            }
            .highlightCard()
        }
    }
    
    var reasonInput: some View {
        VStack(alignment: .leading) {
            Text("Why do you want to do this?")
            TextEditor(text: $viewModel.reason)
                .frame(height: Constants.textEditorHeight)
                .whiteBoxTextFieldStyle()
            
        }
        .highlightCard()
    }
    
    var createHabitButton: some View {
        LongButton(text: "Create habit") {
            Task {
                await viewModel.addHabit(session: userSession)
            }
        }
        .disabled(!viewModel.allFieldsFilled)
    }
    
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
            .environmentObject(UserSession())
    }
}
