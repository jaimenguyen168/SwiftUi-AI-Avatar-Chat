//
//  HeroCellView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/20/24.
//

import SwiftUI

struct HeroCellView: View {
    
    var title: String? = "Some title"
    var subtitle: String? = "Some subtitle goes here"
    var imageUrl: String? = Constants.randomImageurl
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageUrl {
                ImageLoaderView(urlString: imageUrl)
            } else {
                Rectangle()
                    .fill(.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.headline)
                }
                
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .lineLimit(1)
                }
            }
            .foregroundStyle(.white)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .linearGradient(
                    colors: [
                        .black.opacity(0),
                        .black.opacity(0.3),
                        .black.opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    ScrollView(showsIndicators: false) {
        VStack(spacing: 12) {
            HeroCellView()
                .frame(width: 300, height: 200)
            
            HeroCellView(imageUrl: nil)
                .frame(width: 300, height: 200)
            
            HeroCellView(title: nil)
                .frame(width: 300, height: 200)
            
            HeroCellView(subtitle: nil)
                .frame(width: 300, height: 200)
            
            HeroCellView(subtitle: "This is a very long subtitle to display how the text display works")
                .frame(width: 300, height: 200)
            
            HeroCellView()
                .frame(width: 200, height: 400)
        }
    }
}
