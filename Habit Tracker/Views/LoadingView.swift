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
            GeometryReader { proxy in
                let size = min(proxy.size.width, proxy.size.height)
                
                ZStack {
                    Color.clear
                        .ignoresSafeArea()
                        .background(.ultraThinMaterial)
                    
                    Color.highlightColour
                        .frame(
                            width: size * 0.8,
                            height: size * 0.8
                        )
                        .cornerRadius(Constants.cornerRadius)
                 
                    VStack {
                        Text(placeholder)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        ProgressView()
                            .tint(.textColour)
                            .scaleEffect(1.5, anchor: .center)
                    }
                    .titleStyle()
                    .foregroundColor(.textColour)
                }
                .basicShadow()
            }
        }
    }
}


struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(placeholder: "Loading", isLoading: .constant(true))
    }
}
