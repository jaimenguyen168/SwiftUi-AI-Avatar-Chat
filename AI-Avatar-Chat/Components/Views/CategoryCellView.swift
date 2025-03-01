//
//  CategoryCellView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/21/24.
//

import SwiftUI

struct CategoryCellView: View {
    
    var title: String = "Alien"
    var imageUrl: String = Constants.randomImageUrl
    var font: Font = .title2
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        ImageLoaderView( urlString: imageUrl)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .bottomLeading) {
                Text(title)
                    .font(font)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(16)
                    .gradientBackgroundForLeadingText()
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
    }
}

#Preview {
    CategoryCellView()
        .frame(width: 150)
    
    CategoryCellView(
        title: "Dog",
        cornerRadius: 50
    )
        .frame(width: 250)
}
