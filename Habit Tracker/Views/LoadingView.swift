//
//  LoadingView.swift
//  Habit Tracker
//
//  Created by Tino on 15/5/2022.
//

import SwiftUI

struct LoadingView: View {
    let placeholder: String
    @Binding var isLoading: Bool
    
    var body: some View {
        if isLoading {
            ZStack {
                Color(.white)
                    .opacity(0.75)
                    .ignoresSafeArea()
                VStack {
                    Text(placeholder)
                        .font(.title2)
                        .foregroundColor(.black)
                    ProgressView()
                        .tint(.black)
                        .scaleEffect(1.5, anchor: .center)
                }
            }
        } else {
            EmptyView()
        }
    }
}


struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(placeholder: "test", isLoading: .constant(true))
    }
}
