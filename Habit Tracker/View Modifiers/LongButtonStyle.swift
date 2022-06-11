//
//  LongButtonStyle.swift
//  Habit Tracker
//
//  Created by Tino on 10/6/2022.
//

import SwiftUI

struct LongButtonStyle: ViewModifier {
    let proxy: GeometryProxy
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: proxy.size.width * 0.7)
            .title2Style()
            .background(Color.primaryColour)
            .cornerRadius(30)
            .shadow(
                color: .black.opacity(Constants.shadowOpacity),
                radius: Constants.shadowRadius,
                x: 0,
                y: 5
            )
    }
}

extension View {
    func longButtonStyle(proxy: GeometryProxy) -> some View {
        modifier(LongButtonStyle(proxy: proxy))
    }
}
