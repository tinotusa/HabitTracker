//
//  Activity.swift
//  Habit Tracker
//
//  Created by Tino on 2/7/2022.
//

import Foundation
/// An activity the user would like to do instead of the habit they are trying to quit.
struct Activity: Identifiable, Codable, Equatable {
    var id = UUID().uuidString
    /// The name of the activity.
    var name: String
    /// A boolean value indicating whether or not the user has completed this activity instead of the habit they are trying to quit.
    var isCompleted: Bool
    
    init(name: String, isCompleted: Bool = false) {
        self.name = name
        self.isCompleted = isCompleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        guard !name.isEmpty && name.count <= InputFieldCharLimit.activityNameCharLimit else {
            throw DecodingError.dataCorruptedError(forKey: .name, in: container, debugDescription: "Invalid activity name.")
        }
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
    }
}
