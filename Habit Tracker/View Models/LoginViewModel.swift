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
    
    let emailPlaceholder = "Email"
    let passwordPlaceholder = "Password"
    
    private static let saveFilename = "userDetails"
    
    var allFieldsFilled: Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return !email.isEmpty && !password.isEmpty
    }
}

extension LoginViewModel {
    struct LoginDetails: Codable {
        var email: String
        var password: String
    }
    
    enum InputField: Hashable {
        case username
        case password
    }
}

extension FileManager {
    static func documentsDirectory() -> URL {
        Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}


extension LoginViewModel {
    func getLoginDetails() {
        let documentsURL = FileManager.documentsDirectory()
        let fileURL = documentsURL.appendingPathComponent(Self.saveFilename)
        do {
            let data = try Data(contentsOf: fileURL)
            let loginDetails = try JSONDecoder().decode(LoginDetails.self, from: data)
            email = loginDetails.email
            password = loginDetails.password
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
    
    func saveLoginDetails() {
        let url = FileManager.documentsDirectory()
        let saveURL = url.appendingPathComponent(Self.saveFilename)
        let userLoginDetails = LoginDetails(email: email, password: password)
        
        do {
            let data = try JSONEncoder().encode(userLoginDetails)
            try data.write(to: saveURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Error in \(#function)\n\(error)")
        }
    }
}
