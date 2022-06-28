//
//  CustomDivider.swift
//  Habit Tracker
//
//  Created by Tino on 28/6/2022.
//

import SwiftUI

struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.textColour.opacity(0.3))
    }
}


struct CustomDivider_Previews: PreviewProvider {
    static var previews: some View {
        CustomDivider()
    }
}
