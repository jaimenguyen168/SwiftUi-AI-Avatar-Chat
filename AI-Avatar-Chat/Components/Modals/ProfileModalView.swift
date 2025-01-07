//
//  ProfileModalView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/5/25.
//

import SwiftUI

struct ProfileModalView: View {
    
    var imageName: String? = Constants.randomImageUrl
    var title: String? = "Alpha"
    var subtitle: String? = "alien"
    var headline: String? = "An alien is playing in the park"
    var onXmarkPress: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 0) {
            if let imageName {
                ImageLoaderView(
                    urlString: imageName,
                    forceTransitionAnimation: true
                )
                .aspectRatio(1, contentMode: .fit)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                
                if let subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                
                if let headline {
                    Text(headline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(.thinMaterial)
        .customCornerRadius(16)
        .overlay(
            Image(systemName: "xmark")
                .font(.headline)
                .foregroundStyle(.black)
                .padding(6)
                .background(.regularMaterial)
                .tappableBackground()
                .clipShape(Circle())
                .customButton {
                    onXmarkPress()
                }
                .padding()
            
            , alignment: .topTrailing
        )
    }
}

#Preview("Modal with Image") {
    ZStack {
        Color.secondary.ignoresSafeArea()
        
        ProfileModalView()
            .padding(40)
    }
}

#Preview("Modal without Image") {
    ZStack {
        Color.secondary.ignoresSafeArea()
        
        ProfileModalView(imageName: nil)
            .padding(40)
    }
}
