//
//  ImageLoaderView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/20/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageLoaderView: View {
    
    var urlString = Constants.randomImageUrl
    var resizingMode: ContentMode = .fill
    
    var body: some View {
        Rectangle()
            .opacity(0)
            .overlay {
                WebImage(url: URL(string: urlString))
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: resizingMode)
                    .allowsHitTesting(false)
            }
            .clipped()
    }
}

#Preview {
    ImageLoaderView()
        .frame(width: 200, height: 300)
}
