//
//  LongButton.swift
//  Habit Tracker
//
//  Created by Tino on 26/6/2022.
//

import SwiftUI

struct LongButton: View {
    let text: LocalizedStringKey
    let action: (() -> Void)?
    let isDisabled: Bool
    
    init(text: LocalizedStringKey, isDisabled: Bool = false, action: (() -> Void)? = nil) {
        self.text = text
        self.action = action
        self.isDisabled = isDisabled
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
                    .opacity(isDisabled ? 0.5 : 1.0)
                    .cornerRadius(Constants.buttonCornerRadius)
                    .basicShadow()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .disabled(isDisabled)
        }
        // TODO: fix this. this is really hacky.
        .frame(height: 60)
    }
}

struct LongButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LongButton(text: "Testing")
            LongButton(text: "Testing disabled", isDisabled: true)
        }
    }
}
