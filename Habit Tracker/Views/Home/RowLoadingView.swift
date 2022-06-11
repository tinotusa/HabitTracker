//
//  RowLoadingView.swift
//  Habit Tracker
//
//  Created by Tino on 11/6/2022.
//

import SwiftUI

struct RowLoadingView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Title")
                    .title2Style()
                    .redacted(reason: .placeholder)
                Text("Some redacted text")
                    .title2Style()
                    .redacted(reason: .placeholder)
            }
            Spacer()
            RightArrow()
                .opacity(0.4)
        }
        .padding()
        .background(Color.highlightColour)
//        .frame(height: 100)
        .cornerRadius(Constants.cornerRadius)
        .shadow(
            color: .shadow.opacity(Constants.shadowOpacity),
            radius: Constants.shadowRadius,
            x: 0,
            y: 5
        )
    }
}

struct RowLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        RowLoadingView()
    }
}
