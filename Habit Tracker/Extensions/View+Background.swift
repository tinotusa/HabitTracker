//
//  View+Background.swift
//  Habit Tracker
//
//  Created by Tino on 26/6/2022.
//

import SwiftUI

struct BackgroundView: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.backgroundColour
                .ignoresSafeArea()
            
            content
        }
    }
}

extension View {
    func backgroundView() -> some View {
        modifier(BackgroundView())
    }
}
