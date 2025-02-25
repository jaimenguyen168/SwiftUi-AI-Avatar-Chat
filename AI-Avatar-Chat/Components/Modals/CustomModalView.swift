//
//  CustomModalView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/23/25.
//

import SwiftUI

struct CustomModalView: View {
    
    var title: String = "Title"
    var subtitle: String? = "This should be a subtitle"
    var primaryButtonText: String = "Yes"
    var primaryButtonAction: () -> Void = { }
    var secondaryButtonText: String = "No"
    var secondaryButtonAction: () -> Void = { }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            
            VStack(spacing: 8) {
                Text(primaryButtonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.accent)
                    .foregroundStyle(.white)
                    .customCornerRadius(16)
                    .customButton(.pressable) {
                        primaryButtonAction()
                    }
                
                Text(secondaryButtonText)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .tappableBackground()
                    .customButton {
                        secondaryButtonAction()
                    }
            }
        }
        .multilineTextAlignment(.center)
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .customCornerRadius(16)
        .padding(40)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CustomModalView(
            title: "Are you enjoying AI Chat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonText: "Yes",
            primaryButtonAction: {
                
            },
            secondaryButtonText: "No",
            secondaryButtonAction: {
                
            }
        )
    }
}
