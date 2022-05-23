//
//  Tab.swift
//  Habit Tracker
//
//  Created by Tino on 23/5/2022.
//

/// A value that represents the custom tabbar's buttons.
enum Tab: String, CaseIterable, Identifiable {
    case journal = "Journal"
    case home = "Home"
    case add = "Add"
    case calendar = "Calendar"
    
    /// Returns the id of the current tab.
    var id: Self { self }
    
    /// Returns the sf image name for the given tab.
    var imageName: String {
        switch self {
        case .journal: return "book"
        case .home: return "house"
        case .add: return "plus"
        case .calendar: return "calendar"
        }
    }
}
