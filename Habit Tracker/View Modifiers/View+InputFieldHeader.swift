//
//  View+InputFieldHeader.swift
//  Habit Tracker
//
//  Created by Tino on 12/7/2022.
//

import SwiftUI

/// The title and help button for an input field.
struct InputFieldHeader: ViewModifier {
    /// The header/title of the input field.
    let title: LocalizedStringKey
    /// The helper text to be displayed when the help button is pressed.
    let helpText: AddViewViewModel.HelpText
    /// A boolean value indicating whether or not to show the given help text.
    @State private var showingHelpText = false
    
    init(title: LocalizedStringKey, helpText: AddViewViewModel.HelpText) {
        self.title = title
        self.helpText = helpText
    }
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            HStack {
                if showingHelpText {
                    Text(helpText.rawValue)
                } else {
                    Text(title)
                }
                Spacer()
                Button {
                    withAnimation {
                        showingHelpText.toggle()
                    }
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.activityDeleteColour)
                }
            }
            .multilineTextAlignment(.leading)
            .foregroundColor(.textColour)
            content
        }
    }
}

extension View {
    /// Adds a header title and a question mark button to the view.
    func inputFieldHeader(title: LocalizedStringKey, helpText: AddViewViewModel.HelpText) -> some View {
        modifier(InputFieldHeader(title: title, helpText: helpText))
    }
}
