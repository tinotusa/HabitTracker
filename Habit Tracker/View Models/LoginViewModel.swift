//
//  LoginViewModel.swift
//  Habit Tracker
//
//  Created by Tino on 3/5/2022.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = "test@test.com"
    @Published var password = "123456"
    @Published var showSignUpView = false
    @Published var showPasswordResetView = false
}
