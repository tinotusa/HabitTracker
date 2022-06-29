//
//  ActionNotificationBar.swift
//  Habit Tracker
//
//  Created by Tino on 29/6/2022.
//

import SwiftUI

struct ActionNotificationBar: View {
    let text: LocalizedStringKey
    var icon: String? = nil
    @Binding var showingNotification: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(text)
                    .foregroundColor(.textColour)
                    .title2Style()
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showingNotification = false
                    }
                }
            }
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                showingNotification = false
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
