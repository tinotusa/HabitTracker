//
//  TextStyles.swift
//  Habit Tracker
//
//  Created by Tino on 9/6/2022.
//

import SwiftUI

struct TextStyles: View {
    var body: some View {
        ZStack {
            Color("backgroundColour")
                .ignoresSafeArea()
            VStack {
                Text("Styles:")
                    .foregroundColor(Color("textColour"))
                Text("Title style")
                    .titleStyle()
                Text("Body style")
                    .bodyStyle()
            }
        }
        
        
    }
}

struct TextStyle {
    static let fontName = "SF Pro"
    static let titleSize = 40.0
    static let bodySize = 24.0
    static let colour = Color("textColour")
}

struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(TextStyle.fontName, size: TextStyle.titleSize, relativeTo: .title))
            .foregroundColor(TextStyle.colour)
    }
}

struct BodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(TextStyle.fontName, size: TextStyle.bodySize, relativeTo: .body))
            .foregroundColor(TextStyle.colour)
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(TitleStyle())
    }
    
    func bodyStyle() -> some View {
        modifier(BodyStyle())
    }
}

struct TextStyles_Previews: PreviewProvider {
    static var previews: some View {
        TextStyles()
    }
}
