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
            Spacer()
            ForEach(Tab.allCases, id: \.self) { tab in
                HStack {
                    Image(systemName: tab.imageName)
                        .font(.largeTitle)
                        .onTapGesture {
                            selectedTab = tab
                        }
                    if selectedTab == tab {
                        Text(tab.rawValue)
                            .font(.title2)
                    }
                }
                if tab != Tab.allCases.last! {
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            Spacer()
        }
        .padding()
        .padding(.horizontal)
        .background(.blue)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.home))
    }
}
