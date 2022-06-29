//
//  ActionNotificationBar.swift
//  Habit Tracker
//
//  Created by Tino on 29/6/2022.
//

import SwiftUI

struct ActionNotificationBar: View {
    let text: LocalizedStringKey
    let icon: String?
    @Binding var showingNotification: Bool
    let showProgressCircle: Bool
    let canTapToHide: Bool
    @Binding var willDisappearWhenFalse: Bool
    
    init(
        text: LocalizedStringKey,
        icon: String? = nil,
        showingNotification: Binding<Bool> = .constant(false),
        showProgressCircle: Bool = false,
        canTapToHide: Bool = false,
        willDisappearWhenFalse: Binding<Bool> = .constant(false)
    ) {
        self.text = text
        self.icon = icon
        _showingNotification = showingNotification
        self.showProgressCircle = showProgressCircle
        self.canTapToHide = canTapToHide
        _willDisappearWhenFalse = willDisappearWhenFalse
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(text)
                    .foregroundColor(.textColour)
                    .title2Style()
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showProgressCircle {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.textColour)
                        .scaleEffect(1.2)
                }
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.primaryColour)
                        .titleStyle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 70)
            .padding()
            .background(Color.highlightColour)
            .cornerRadius(Constants.cornerRadius)
            .basicShadow()
            .onAppear {
                if willDisappearWhenFalse {
                    // No need to time the removal
                    // when the binding is false the notification will be removed.
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showingNotification = false
                        }
                    }
                    print("here2")
                }
            }
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            if canTapToHide {
                withAnimation {
                    showingNotification = false
                }
            }
        }
    }
}

struct ActionNotificationBar_Previews: PreviewProvider {
    static var previews: some View {
        ActionNotificationBar(
            text: "Hello world",
            icon: "checkmark.circle.fill",
            showingNotification: .constant(false)
        )
    }
}
