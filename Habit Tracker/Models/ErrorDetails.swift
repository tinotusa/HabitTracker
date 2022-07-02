//
//  ErrorDetails.swift
//  Habit Tracker
//
//  Created by Tino on 15/5/2022.
//

import Foundation
import SwiftUI

struct ErrorDetails: Identifiable {
    let id = UUID().uuidString
    var name: LocalizedStringKey
    var message: LocalizedStringKey
}
