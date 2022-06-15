//
//  BasicShadow.swift
//  Habit Tracker
//
//  Created by Tino on 15/6/2022.
//

import SwiftUI

struct BasicShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(
                color: .shadow.opacity(Constants.shadowOpacity),
                radius: Constants.shadowRadius,
                x: 0,
                y: 5
            )
    }
}

extension View {
    func basicShadow() -> some View {
        modifier(BasicShadow())
    }
}
