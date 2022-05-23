//
//  AddView.swift
//  Habit Tracker
//
//  Created by Tino on 23/5/2022.
//

import SwiftUI

struct AddView: View {
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.4)
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("Add habit")
                    Text("something here")
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
