//
//  View+ActionNotification.swift
//  Habit Tracker
//
//  Created by Tino on 1/7/2022.
//

import SwiftUI

struct ActionNotification: ViewModifier {
    /// The label for the notification.
    let text: LocalizedStringKey
    /// An sf symbole name.
    let icon: String?
    /// A binding to a bool that indicates whether or not the notification bar is showing.
    @Binding var showingNotification: Bool
    /// Whether to show a progress circle or not.
    let showProgressCircle: Bool
    /// A boolean value that indicates whether or not the notification can be tapped and hidden by the user.
    let canTapToHide: Bool
    /// A Binding to tell the notification when to disappear
    @Binding var willDisappearWhenFalse: Bool
    
    func body(content: Content) -> some View {
        content
            .disabled(showingNotification)
            .overlay {
                if showingNotification {
                    ActionNotificationBar(
                        text: text,
                        icon: icon,
                        showingNotification: $showingNotification,
                        showProgressCircle: showProgressCircle,
                        canTapToHide: canTapToHide,
                        willDisappearWhenFalse: $willDisappearWhenFalse
                    )
                    .transition(.move(edge: .top))
                }
            }
    }
}

extension View {
    func actionNotification(
        text: LocalizedStringKey,
        icon: String? = nil,
        showingNotifiction: Binding<Bool>,
        showProgressCircle: Bool = false,
        canTapToHide: Bool = true,
        willDisappearWhenFalse: Binding<Bool> = .constant(false)
    ) -> some View {
        modifier(
            ActionNotification(
                text: text,
                icon: icon,
                showingNotification: showingNotifiction,
                showProgressCircle: showProgressCircle,
                canTapToHide: canTapToHide,
                willDisappearWhenFalse: willDisappearWhenFalse
            )
         )
    }
}
