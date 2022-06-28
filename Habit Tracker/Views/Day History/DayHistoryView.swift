//
//  DayHistoryView.swift
//  Habit Tracker
//
//  Created by Tino on 1/6/2022.
//

import SwiftUI

struct DayHistoryView: View {
    let date: Date
    @EnvironmentObject var userSession: UserSession
    @StateObject var viewModel = DayHistoryViewViewModel()
    @State private var selectedEntry: JournalEntry? = nil
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                dismiss()
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
            
            if viewModel.hasEntries {
                entryTabs
                CustomDivider()
                if let selectedEntry = selectedEntry {
                    JournalDetails(entry: selectedEntry)
                        .id(UUID())
                        .transition(.identity)
                } else {
                    Spacer()
                    Text("Select an entry to view")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                Spacer()
            } else {
                Spacer()
                Text("No journal entries for this date.")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .title2Style()
        .foregroundColor(.textColour)
        .backgroundView()
        .navigationBarHidden(true)
        .task {
            if !userSession.isSignedIn {
                return
            }
            await viewModel.getHabits(for: date, userSession: userSession)
        }
    }
}

private extension DayHistoryView {
    @ViewBuilder
    var entryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.journalEntries) { entry in
                    VStack {
                        Text(entry.habitName)
                            .padding()
                            .background(selectedEntry != nil && selectedEntry!.id == entry.id ? Color.primaryColour : Color.highlightColour)
                            .cornerRadius(Constants.cornerRadius)
                            .foregroundColor(.textColour)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selectedEntry = entry
                        }
                    }
                }
            }
        }
    }
}

struct DayHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DayHistoryView(date: Date())
            .environmentObject(UserSession())
    }
}
