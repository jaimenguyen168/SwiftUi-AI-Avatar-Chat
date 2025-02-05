//
//  DevSettingsView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/5/25.
//

import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    
    var body: some View {
        NavigationStack {
            List {
                authSection

                userSection
                
                deviceSection
            }
            .navigationTitle("Dev Settings 🕹️")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    dismissButton
                }
            }
        }
    }
}

// MARK: Views Section
private extension DevSettingsView {
    var dismissButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .customButton {
                dismiss()
            }
    }
    
    func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            
            if let value = item.value as? Date {
                Text(value.formatted())
            } else {
                Text(String(describing: item.value))
            }
        }
        .font(.footnote)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    var authSection: some View {
        Section {
            let array = authManager.authUser?
                .eventParameters
                .asAlphabeticalArray ?? []
                
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    var userSection: some View {
        Section {
            let array = userManager.currentUser?
                .eventParameters
                .asAlphabeticalArray ?? []
                
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    var deviceSection: some View {
        Section {
            let array = Utilities
                .eventParameters
                .asAlphabeticalArray
                
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }
}

#Preview {
    DevSettingsView()
        .previewAllEnvironments()
}
