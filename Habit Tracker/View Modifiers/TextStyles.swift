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
            BackgroundView()
            
            VStack {
                Text("Styles:")
                    .foregroundColor(.textColour)
                Text("Title style")
                    .titleStyle()
                Text("Title 2 style")
                    .title2Style()
                Text("Caption style")
                    .captionStyle()
            }
        }
        
        
    }
}

struct TextStyle {
    static let fontName = "SF Pro"
    static let titleSize = 40.0
    static let captionSize = 20.0
    static let title2Size = 24.0
    static let colour = Color.textColour // TODO: might remove this (colour can be added to a specific text when needed)
}

struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(TextStyle.fontName, size: TextStyle.titleSize, relativeTo: .title))
            .foregroundColor(TextStyle.colour)
    }
}

struct CaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(TextStyle.fontName, size: TextStyle.captionSize, relativeTo: .subheadline))
    }
}
struct Title2Style: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(TextStyle.fontName, size: TextStyle.title2Size, relativeTo: .body))
            .foregroundColor(TextStyle.colour)
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(TitleStyle())
    }
    
    func title2Style() -> some View {
        modifier(Title2Style())
    }
    
    func captionStyle() -> some View {
        modifier(CaptionStyle())
    }
}

struct TextStyles_Previews: PreviewProvider {
    static var previews: some View {
        TextStyles()
    }
}
