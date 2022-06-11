//
//  BackgroundView.swift
//  Habit Tracker
//
//  Created by Tino on 11/6/2022.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        Color.backgroundColour
            .ignoresSafeArea()
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
