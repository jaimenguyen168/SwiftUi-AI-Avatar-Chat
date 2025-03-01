//
//  ChatRowCellView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/23/24.
//

import SwiftUI

struct ChatRowCellView: View {
    
    var imageUrl: String? = Constants.randomImageUrl
    var headline: String? = "Alien"
    var subheadline: String? = "This is the last message since last time"
    var hasNewMessage: Bool = true
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if let imageUrl {
                    ImageLoaderView(urlString: imageUrl)
                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.5))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                if let headline {
                    Text(headline)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                
                if let subheadline {
                    Text(subheadline)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 4)
            
            if hasNewMessage {
                Text("NEW")
                    .blueBadge()
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .frame(maxWidth: 50)
            }
        }
        .padding(12)
    }
}

#Preview {
    List {
        ChatRowCellView()
            .listRowInsets(EdgeInsets(.zero))
        
        ChatRowCellView(imageUrl: nil, subheadline: "How are you?")
        
        ChatRowCellView(imageUrl: nil, subheadline: "How are you?", hasNewMessage: false)
    }
}
