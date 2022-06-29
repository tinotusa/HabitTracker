//
//  NavigationArrowIndicator.swift
//  Habit Tracker
//
//  Created by Tino on 29/6/2022.
//

import SwiftUI

struct NavigationArrowIndicator: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .title2Style()
            .foregroundColor(.textColour)
            .padding(.trailing)
    }
}

struct NavigationArrowIndicator_Previews: PreviewProvider {
    static var previews: some View {
        NavigationArrowIndicator()
    }
}
