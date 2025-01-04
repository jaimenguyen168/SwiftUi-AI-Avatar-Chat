//
//  ChatBubbleView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/3/25.
//

import SwiftUI

struct ChatBubbleView: View {
    
    var text: String = "Hello, World!"
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray5)
    var showImage: Bool = true
    var imageName: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showImage {
                ZStack {
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                    } else {
                        Rectangle()
                            .fill(.secondary)
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
            }
            
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ChatBubbleView()
            ChatBubbleView(
                text: "Hello there",
                imageName: Constants.randomImageUrl
            )
            ChatBubbleView(
                text: "This is a chat from current user",
                textColor: .white,
                backgroundColor: .accent,
                showImage: false
            )
        }
    }
}
