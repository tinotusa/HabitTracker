//
//  RatingView.swift
//  Habit Tracker
//
//  Created by Tino on 30/5/2022.
//

import SwiftUI

/// A star rating view.
struct RatingView: View {
    /// The rating.
    @Binding var rating: Int
    /// The max rating.
    let maxRating: Int
    
    init(rating: Binding<Int>, maxRating: Int = 5) {
        _rating = rating
        self.maxRating = maxRating
    }
    
    var body: some View {
        HStack {
            ForEach(1 ..< 6) { rating in
                getStar(for: rating)
                    .onTapGesture {
                        withAnimation {
                            self.rating = rating
                        }
                    }
            }
        }
    }
    
    /// Returns the image for the current rating.
    @ViewBuilder
    func getStar(for rating: Int) -> some View {
        if rating <= self.rating {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
        } else {
            Image(systemName: "star")
                .foregroundColor(.gray)
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(0 ..< 5) { index in
                RatingView(rating: .constant(index + 1))
            }
        }
    }
}
