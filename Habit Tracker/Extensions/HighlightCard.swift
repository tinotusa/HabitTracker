//
//  HighlightCard.swift
//  Habit Tracker
//
//  Created by Tino on 15/6/2022.
//

import SwiftUI

struct HighlightCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.highlightColour)
            .cornerRadius(Constants.cornerRadius)
            .basicShadow()
    }
}

extension View {
    func highlightCard() -> some View {
        modifier(HighlightCard())
    }
}
