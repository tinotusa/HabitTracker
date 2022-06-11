//
//  InputField.swift
//  Habit Tracker
//
//  Created by Tino on 9/6/2022.
//

import Foundation
import SwiftUI

struct InputField: ViewModifier {
    let imageName: String
    let contentType: UITextContentType?
    let onSubmitAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        VStack {
            HStack {
                content
                    .textContentType(contentType)
                    .foregroundColor(.textColour)
                    .title2Style()
                    .disableAutocorrection(true)
                    .submitLabel(.next)
                    .onSubmit {
                        onSubmitAction?()
                    }
                Image(systemName: imageName)
                    .foregroundColor(.textColour)
                    .font(.title)
            }
            Rectangle()
                .foregroundColor(.textColour.opacity(0.8))
                .frame(height: 1)
        }
    }
}

struct PasswordField: ViewModifier {
    let contentType: UITextContentType?
    let onSubmitAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        VStack {
            HStack {
                content
                    .textContentType(contentType)
                    .foregroundColor(.textColour)
                    .title2Style()
                    .onSubmit {
                        onSubmitAction?()
                    }
                Image(systemName: "lock.fill")
                    .foregroundColor(.textColour)
                    .font(.title)
            }
            Rectangle()
                .foregroundColor(.textColour.opacity(0.8))
                .frame(height: 1)
        }
    }
}


extension View {
    func inputField(
        imageName: String = "person.fill",
        contentType: UITextContentType? = nil,
        onSubmitAction: (() -> Void)? = nil
    ) -> some View {
        modifier(InputField(imageName: imageName, contentType: contentType, onSubmitAction: onSubmitAction))
    }
    
    func passwordField(contentType: UITextContentType? = nil, onSubmitAction: (() -> Void)? = nil) -> some View {
        modifier(PasswordField(contentType: contentType, onSubmitAction: onSubmitAction))
    }
}
