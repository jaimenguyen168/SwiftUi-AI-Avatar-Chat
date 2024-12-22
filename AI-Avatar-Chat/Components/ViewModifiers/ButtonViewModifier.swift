//
//  ButtonViewModifier.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/22/24.
//

import SwiftUI

struct HighlightButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 16
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        configuration.isPressed
                        ? Color.accent.opacity(0.4)
                        : Color.accent.opacity(0)
                    )
            }
            .animation(.snappy, value: configuration.isPressed)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(
                configuration.isPressed ? 0.9 : 1
            )
            .animation(.snappy, value: configuration.isPressed)
    }
}

enum ButtonStyleOption {
    case highlight(cornerRadius: CGFloat = 16), pressable, plain
}

extension View {
    
    @ViewBuilder
    func customButton(
        _ option: ButtonStyleOption = .plain,
        action: @escaping () -> Void
    ) -> some View {
        
        switch option {
        case .highlight(let cornerRadius):
            self.highlightButton(
                cornerRadius: cornerRadius,
                action: action
            )
        case .pressable:
            self.pressableButton(action: action)
        case .plain:
            self.plainButton(action: action)
        }
    }
    
    private func highlightButton(
        cornerRadius: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(HighlightButtonStyle(cornerRadius: cornerRadius))
    }
    
    private func pressableButton(action: @escaping () -> Void ) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(PressableButtonStyle())
    }
    
    private func plainButton(action: @escaping () -> Void ) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Button {
            //
        } label: {
            Text("Click Me")
                .padding()
                .frame(maxWidth: .infinity)
                .tappableBackground()
                .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(HighlightButtonStyle())
        
        Text("Click Me With Default Highlight")
            .padding()
            .frame(maxWidth: .infinity)
            .tappableBackground()
            .customButton(.highlight()) {
                //
            }
        
        Text("Click Me With Custom Style")
            .padding()
            .frame(maxWidth: .infinity)
            .tappableBackground()
            .customButton(.highlight(cornerRadius: 50)) {
                //
            }
        
        Text("Click Me With Scale Effect")
            .padding()
            .frame(maxWidth: .infinity)
            .callToActionButton()
            .customButton(.pressable) {
                //
            }
        
        Text("Click Me With Plain Style")
            .padding()
            .frame(maxWidth: .infinity)
            .callToActionButton()
            .customButton(.plain) {
                //
            }
    }
    .padding()
}
