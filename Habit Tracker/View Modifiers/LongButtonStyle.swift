//
//  LongButtonStyle.swift
//  Habit Tracker
//
//  Created by Tino on 10/6/2022.
//

import SwiftUI

struct LongButtonStyle: ButtonStyle {
    let proxy: GeometryProxy
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: proxy.size.width * 0.7)
            .bodyStyle()
            .background(configuration.isPressed ? Color("primaryColour").opacity(0.8) : Color("primaryColour"))
            .cornerRadius(30)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 5)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
