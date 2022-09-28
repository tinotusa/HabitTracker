//
//  JournalDetails.swift
//  Habit Tracker
//
//  Created by Tino on 28/6/2022.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class JournalDetailsViewModel: ObservableObject {
    @Published var habit: Habit?
    private lazy var firestore = Firestore.firestore()
    
    func getHabit(byID id: String, userSession: UserSession) async -> Habit? {
        guard let user = userSession.currentUser else {
            preconditionFailure("User is not signed in.")
        }
        let query = firestore
            .collectionGroup("habits")
            .whereField("createdBy", isEqualTo: user.uid)
            .whereField("id", isEqualTo: id)
            .limit(to: 1)
        
        do {
            let snapshot = try await query.getDocuments()
            return try snapshot.documents.first!.data(as: Habit.self)
        } catch {
            print("Error in \(#function)\n\(error)")
        }
        return nil
    }
}

struct JournalDetails: View {
    let entry: JournalEntry
    @State private var habit: Habit?
    @StateObject var viewModel = JournalDetailsViewModel()
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Constants.vstackSpacing) {
                VStack(alignment: .leading, spacing: Constants.habitRowVstackSpacing) {
                    Text("Created on: \(entry.dateCreated.formatted(date: .long, time: .omitted))")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .highlightCard()
                
                VStack(alignment: .leading, spacing: Constants.habitRowVstackSpacing) {
                    Text("Entry:")
                    TextEditor(text: .constant(entry.entry))
                        .textSelection(.enabled)
                        .frame(maxHeight: Constants.entryDetailHeight)
                        .whiteBoxTextFieldStyle()
                }
                .highlightCard()
                
                if let habit = habit, habit.habitState == .quitting {
                    VStack(alignment: .leading, spacing: Constants.habitRowVstackSpacing) {
                        Text("You did this:")
                        ForEach(entry.activities) { activity in
                            if activity.isCompleted {
                                Text(activity.name)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .highlightCard()
                }
                
                VStack(spacing: Constants.habitRowVstackSpacing) {
                    Text("Rating")
                    RatingView(rating: .constant(entry.rating))
                }
                .frame(maxWidth: .infinity)
                .highlightCard()
                
                Spacer(minLength: 60) 
            }
            .title2Style()
            .foregroundColor(.textColour)
        }
        .task {
            if !userSession.isSignedIn {
                return
            }
            habit = await viewModel.getHabit(byID: entry.habitID, userSession: userSession)
        }
    }
}

struct JournalDetails_Previews: PreviewProvider {
    static var previews: some View {
        JournalDetails(entry: JournalEntry.example)
            .backgroundView()
            .environmentObject(UserSession())
    }
}
