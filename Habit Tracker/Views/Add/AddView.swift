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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Add habit")
                Toggle("Quitting habbit", isOn: $viewModel.isQuittingHabit)
                Toggle("Starting habbit", isOn: $viewModel.isStartingHabit)
            
                TextField("Habit name", text: $viewModel.habitName, prompt: Text("Habit name"))
                
                VStack(alignment: .leading) {
                    Text("When do you usually do this?")
                    DayPickerView(selection: $viewModel.occurrenceDays)
                    DatePicker(
                        "Time",
                        selection: $viewModel.occurrenceTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                }
                
                VStack(alignment: .leading) {
                    Text("How long does it usually take to do it?")
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
                
                // where does it usually happen?
                if viewModel.isQuittingHabit {
                    Group {
                        Text("What do you want to do instead?")
                        HStack {
                            TextField("", text: $viewModel.activityInput, prompt: Text("I want to..."))
                            Button("Add") {
                                viewModel.addActivity()
                            }
                        }
                        ForEach(viewModel.activities) { activity in
                            HStack {
                                Text(activity.name)
                                Button {
                                    viewModel.removeActivity(activity: activity)
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                    }
                }
                if viewModel.isQuittingHabit {
                    Group {
                        Text("Why do you want to quit this habit?")
                        TextField("Reason", text: $viewModel.reason, prompt: Text("Placeholder"))
                    }
                }
                if viewModel.isStartingHabit {
                    Group {
                        Text("Why do you want to start this habit?")
                        TextField("Reason", text: $viewModel.reason, prompt: Text("Placeholder"))
                    }
                }
                
                Button("Add habit") {
                    Task {
                        await viewModel.addHabit(session: userSession)
                    }
                }
                .disabled(!viewModel.allFieldsFilled)
            }
            .padding()
        }
        .alert(
            "Get permissions",
            isPresented: $viewModel.showSettingsForPermissions,
            presenting: viewModel.permissionsDetails
        ) { details in
            Button(role: .cancel){
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

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
            .environmentObject(UserSession())
    }
}
