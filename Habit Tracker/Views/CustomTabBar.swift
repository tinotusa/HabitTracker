//
//  CustomTabBar.swift
//  Habit Tracker
//
//  Created by Tino on 23/5/2022.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    init(selectedTab: Binding<Tab>) {
        _selectedTab = selectedTab
    }
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                VStack {
                    Image(systemName: tab.imageName)
                        .font(.title)
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            withAnimation {
                                selectedTab = tab
                            }
                        }
                        .frame(maxWidth: .infinity)
                    Text(tab.tabName)
                }
                .padding(.vertical)
                .contentShape(Rectangle())
                .foregroundColor(tab == selectedTab ? .highlightColour : .textColour)
            }
        }
        .background(
            Color.primaryColour
        )
        .cornerRadius(Constants.cornerRadius)
        .padding(.horizontal)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.home))
    }
}
