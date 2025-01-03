//
//  View+Ext.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

extension View {
    static func customWidth(percent: CGFloat) -> CGFloat {
        UIScreen.main.bounds.width * (percent / 100)
    }
    
    func callToActionButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(.accent, in: .rect(cornerRadius: 16))
    }
    
    func blueBadge() -> some View {
        self
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(4)
            .padding(.horizontal, 2)
            .background(.blue)
            .clipShape(.rect(cornerRadius: 6))
    }
    
    func tappableBackground() -> some View {
        background(.black.opacity(0.001))
    }
    
    func formatListRow() -> some View {
        self
            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
    
    func removeBgAndInsetsListRow() -> some View {
        self
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(.zero))
    }
    
    func gradientBackgroundForLeadingText() -> some View {
        self
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
}
