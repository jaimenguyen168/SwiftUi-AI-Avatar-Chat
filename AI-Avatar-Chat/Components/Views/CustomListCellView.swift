//
//  CustomListCellView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/21/24.
//

import SwiftUI

struct CustomListCellView: View {
    
    var title: String? = "Alien"
    var subtitle: String? = "An alien is biking on the beach"
    var imageUrl: String? = Constants.randomImageUrl
    
    var body: some View {
        HStack {
            ZStack {
                if let imageUrl {
                    ImageLoaderView(urlString: imageUrl)
                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.5))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 60)
            .clipShape(.rect(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                if let title {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .lineLimit(2)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.5).ignoresSafeArea()
        
        VStack {
            CustomListCellView()
            
            CustomListCellView(imageUrl: nil)
        }
    }
}
