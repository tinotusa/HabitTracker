//
//  LongButton.swift
//  Habit Tracker
//
//  Created by Tino on 26/6/2022.
//

import SwiftUI

struct LongButton: View {
    let text: String
    let action: (() -> Void)?
    
    init(text: String, action: (() -> Void)? = nil) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        GeometryReader { proxy in
            Button {
                action?()
            } label: {
                Text(text)
                    .foregroundColor(.textColour)
                    .padding()
                    .frame(maxWidth: proxy.size.width * 0.8)
                    .title2Style()
                    .background(Color.primaryColour)
                    .cornerRadius(Constants.buttonCornerRadius)
                    .basicShadow()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // TODO: fix this. this is really hacky.
        .frame(height: 60)
    }
}

struct LongButton_Previews: PreviewProvider {
    static var previews: some View {
        LongButton(text: "Testing") 
    }
}
