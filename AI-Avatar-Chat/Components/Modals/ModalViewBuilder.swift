//
//  ModalView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/7/25.
//

import SwiftUI

struct ModalViewBuilder<Content: View>: View {
    
    @Binding var showModal: Bool
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            if showModal {
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.7),
                        .black.opacity(0.5),
                        .black.opacity(0.3),
                        .black.opacity(0.05)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()
                .transition(.fade)
                .onTapGesture {
                    showModal = false
                }
                .zIndex(1)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(2)
            }
        }
        .zIndex(9999)
        .animation(.easeInOut, value: showModal)
    }
}

extension View {
    func showModal(showModal: Binding<Bool>, @ViewBuilder content: () -> some View) -> some View {
        self
            .overlay {
                ModalViewBuilder(
                    showModal: showModal,
                    content: {
                        content()
                    }
                )
            }
    }
}

private struct PreviewView: View {
    
    @State private var showModal = false
    
    var body: some View {
        Button("Show Modal") {
            showModal = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .showModal(showModal: $showModal) {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 250, height: 400)
                .transition(.slide)
                .onTapGesture {
                    showModal = false
                }
        }
    }
}

#Preview {
    PreviewView()
}
