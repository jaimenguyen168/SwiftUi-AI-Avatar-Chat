//
//  OnboardingColorView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/20/24.
//

import SwiftUI

struct OnboardingColorView: View {
    
    @State private var selectedColor: Color?
    let profileColors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .orange, .brown, .cyan, .indigo
    ]
    
    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16) {
            ZStack {
                if let selectedColor {
                    continueButton(selectedColor: selectedColor)
                        .transition(.move(edge: .bottom))
                }
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
        }
        .toolbar(.hidden, for: .navigationBar)
        .animation(.bouncy, value: selectedColor)
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 16),
                count: 3
            ),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders],
            content: {
                Section {
                    ForEach(profileColors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay {
                                Circle()
                                    .fill(.white)
                                    .padding(3)
                                color
                                    .clipShape(Circle())
                                    .padding(selectedColor == color ? 6 : 0)
                            }
                            .onTapGesture {
                                 selectedColor = color
                            }
                    }
                } header: {
                    Text("Select a profile color")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }

            }
        )
    }
    
    private func continueButton(selectedColor: Color) -> some View {
        NavigationLink {
            OnboardingCompletedView(selectedColor: selectedColor)
        } label: {
            Text("Continue")
                .callToActionButton()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView()
    }
    .environment(AppState())
}
