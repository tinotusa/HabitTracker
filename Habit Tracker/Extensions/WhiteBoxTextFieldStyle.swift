//
//  WhiteBoxTextFieldStyle.swift
//  Habit Tracker
//
//  Created by Tino on 15/6/2022.
//

import SwiftUI

struct WhiteBoxTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.textFieldBackgroundColour)
            .cornerRadius(Constants.cornerRadius)
            .foregroundColor(.textFieldTextColour)
            .basicShadow()
    }
}

extension View {
    func whiteBoxTextFieldStyle() -> some View {
        modifier(WhiteBoxTextFieldStyle())
    }
}
