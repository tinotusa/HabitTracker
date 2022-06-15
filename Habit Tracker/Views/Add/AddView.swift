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
        GeometryReader { proxy in
            ZStack {
                BackgroundView()
                
                VStack(alignment: .leading) {
                    Text("Add habit")
                        .titleStyle()
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
                            Toggle("Quitting a habit", isOn: $viewModel.isQuittingHabit.animation())
                            Toggle("Starting a habit", isOn: $viewModel.isStartingHabit.animation())
                            
                            Divider()
                            
                            VStack(alignment: .leading) {
                                Text("Habit name")
                                TextField("Name", text: $viewModel.habitName, prompt: Text(viewModel.habitNamePrompt))
                                    .whiteBoxTextFieldStyle()
                            }
                            .highlightCard()
                            
                            if viewModel.isQuittingHabit {
                                VStack(alignment: .leading) {
                                    Text("When do you usually do this?")
                                    DatePicker("Time", selection: $viewModel.occurrenceTime, displayedComponents: [.hourAndMinute])
                                        .labelsHidden()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .highlightCard()
                                
                            }
                            VStack(alignment: .leading) {
                                Text("What days do you usually this?")
                                DayPickerView(selection: $viewModel.occurrenceDays)
                            }
                            .highlightCard()
                            
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
                                    Button {
                                        viewModel.addActivity()
                                    } label: {
                                        Text("Add")
                                            .longButtonStyle(proxy: proxy)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                }
                                .highlightCard()
                            }
                            VStack(alignment: .leading) {
                                Text("Why do you want to do this?")
                                TextEditor(text: $viewModel.reason)
                                    .frame(height: 100)
                                    .whiteBoxTextFieldStyle()
                            }
                            .highlightCard()
                            Button {
                                Task {
                                    await viewModel.addHabit(session: userSession)
                                }
                            } label: {
                                Text("Create habit")
                                    .longButtonStyle(proxy: proxy)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .disabled(!viewModel.allFieldsFilled)
                        }
                    }
                    .title2Style()
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
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
            .environmentObject(UserSession())
    }
}
