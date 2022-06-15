//
//  ActivityDeleteButton.swift
//  Habit Tracker
//
//  Created by Tino on 14/6/2022.
//

import SwiftUI

struct ActivityDeleteButton: View {
    let action: (() -> Void)?
    
    init(action: (() -> Void)? = nil) {
        self.action = action
    }
    
    var body: some View {
        Button {
            action?()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.activityDeleteColour)
                .titleStyle()
        }
    }
}

struct ActivityDeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        ActivityDeleteButton()
    }
}
