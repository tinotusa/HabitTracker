//
//  LoginViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 3/5/2022.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showSignUpView = false
    @Published var showPasswordResetView = false
}
