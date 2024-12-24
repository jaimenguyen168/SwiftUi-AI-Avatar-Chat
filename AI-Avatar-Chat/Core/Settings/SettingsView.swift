//
//  SettingsView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                
                purchasesSection
                
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView) {
                CreateAccountView()
                    .presentationDetents([.medium])
            }
        }
    }
    
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .customButton(.highlight(cornerRadius: 12)) {
                        onCreateAccountTapped()
                    }
                    .clearListRowBackground()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .customButton(.highlight(cornerRadius: 12)) {
                        onSignOutTapped()
                    }
                    .clearListRowBackground()
            }
            
            Text("Delete account")
                .foregroundStyle(.red)
                .rowFormatting()
                .customButton(.highlight(cornerRadius: 12)) {
                    
                }
                .clearListRowBackground()
        } header: {
            Text("Account")
        }
    }
    
    private var purchasesSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Account status: \(isPremium ? "PREMIUM" : "FREE")")
                
                Spacer(minLength: 0)
                
                if isPremium {
                    Text("MANAGE")
                        .blueBadge()
                }
            }
            .rowFormatting()
            .customButton(.highlight(cornerRadius: 12)) {

            }
            .disabled(!isPremium)
            .clearListRowBackground()
        } header: {
            Text("Purchases")
        }
    }
    
    private var applicationSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Version")
                
                Spacer(minLength: 0)
                
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .clearListRowBackground()
            
            HStack(spacing: 8) {
                Text("Build Number")
                
                Spacer(minLength: 0)
                
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .clearListRowBackground()
            
            Text("Contact us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .customButton(.highlight(cornerRadius: 12)) {
                    
                }
                .clearListRowBackground()
        } header: {
            Text("Application")
        } footer: {
            VStack(alignment: .leading, spacing: 6) {
                Text("Designed by ")
                +
                Text("Swiftful Thinking.")
                    .bold()
                    .foregroundStyle(.black.opacity(0.5))
                
                Text("Developed by ")
                +
                Text("JaimeNguyen168 ")
                    .bold()
                    .foregroundStyle(.accent)
                +
                Text("with ❤️")
                
                Text("Copyright © 2021 Swiftful Thinking.")
            }
        }
    }
    
    private func onSignOutTapped() {
        dismiss()
        Task {
            try? await Task.sleep(for: .seconds(0.1))
            appState.updateViewState(showTabBarView: false)
        }
    }
    
    private func onCreateAccountTapped() {
        showCreateAccountView = true
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemBackground))
    }
    
    func clearListRowBackground() -> some View {
        self
            .listRowInsets(EdgeInsets(.zero))
            .listRowBackground(Color.clear)
    }
}
