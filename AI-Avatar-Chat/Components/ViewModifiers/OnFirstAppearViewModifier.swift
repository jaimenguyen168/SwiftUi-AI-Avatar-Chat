//
//  OnFirstAppearViewModifier.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/27/25.
//

import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !didAppear else { return }
                didAppear = true
                action()
            }
    }
}

struct OnFirstTaskViewModifier: ViewModifier {
    
    @State private var didAppear = false
    let action: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .task {
                guard !didAppear else { return }
                didAppear = true
                await action()
            }
    }
}

extension View {
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearViewModifier(action: action))
    }
    
    func onFirstTask(_ action: @escaping () async -> Void) -> some View {
        modifier(OnFirstTaskViewModifier(action: action))
    }
}
