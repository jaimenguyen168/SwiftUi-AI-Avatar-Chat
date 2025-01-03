//
//  AsyncCallToActionButton.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/3/25.
//

import SwiftUI

struct AsyncCallToActionButton: View {
    
    var title: String = "Save"
    var isLoading: Bool = false
    var action: (() -> Void)?
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
            }
        }
        .callToActionButton()
        .customButton(.pressable) {
            action?()
        }
        .disabled(isLoading)
    }
}

private struct PreviewView: View {
    
    @State private var isLoading = false
    
    var body: some View {
        AsyncCallToActionButton(
            title: "Save",
            isLoading: isLoading,
            action: {
                isLoading = true
                
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    isLoading = false
                }
            }
        )
    }
}

#Preview {
    PreviewView()
        .padding()
}
