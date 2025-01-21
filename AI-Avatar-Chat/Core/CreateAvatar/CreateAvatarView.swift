//
//  CreateAvatarView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/29/24.
//

import SwiftUI

struct CreateAvatarView: View {

    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    
    @Environment(\.dismiss) var dismiss
    @State private var avatarName = ""
    @State private var character: Character = .default
    @State private var action: Action = .default
    @State private var location: Location = .default
    
    @State private var isGenerating = false
    @State private var generatedImage: UIImage?
    @State private var isSaving = false
    
    @State private var showAlert: AppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                nameSection
                
                attributesSection
                
                imageSection
                
                Spacer()
                    .removeBgAndInsetsListRow()
                
                saveSection
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    backButton
                }
            }
            .showCustomAlert(alert: $showAlert)
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.red)
            .customButton {
                onBackButtonPress()
            }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("Name Your Avatar")
        }
    }
    
    private var attributesSection: some View {
        Section {
            Picker(selection: $character) {
                ForEach(Character.allCases) { character in
                    Text(character.rawValue.capitalized)
                        .tag(character)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $action) {
                ForEach(Action.allCases) { action in
                    Text(action.rawValue.capitalized)
                        .tag(action)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $location) {
                ForEach(Location.allCases) { location in
                    Text(location.rawValue.capitalized)
                        .tag(location)
                }
            } label: {
                Text("in the...")
            }
        } header: {
            Text("Attributes")
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top) {
                ZStack {
                    Text("Generate an Image")
                        .underline()
                        .foregroundStyle(.accent)
                        .customButton {
                            onGenerateImagePress()
                        }
                        .opacity(isGenerating ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(isGenerating ? 1 : 0)
                }
                .disabled(isGenerating || avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .clipShape(Circle())
            }
            .removeBgAndInsetsListRow()
            .padding(.horizontal, 4)
        }
    }
    
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                title: "Save",
                isLoading: isSaving,
                action: onSavePress
            )
        }
        .removeBgAndInsetsListRow()
        .opacity(generatedImage == nil ? 0.5 : 1)
        .disabled(generatedImage == nil)
    }
    
    private func onBackButtonPress() {
        dismiss()
    }
    
    private func onGenerateImagePress() {
        isGenerating = true
        
        Task {
            do {
                let prompt = AvatarDescriptionBuilder(
                    character: character,
                    action: action,
                    location: location
                ).description
                
                generatedImage = try await aiManager.generateImage(prompt: prompt)
            } catch {
                showAlert = AppAlert(error: error)
            }
            
            isGenerating = false
        }
    }
    
    private func onSavePress() {
        guard let generatedImage else { return }
        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.validateText(text: avatarName, minimumLength: 4)
                let uid = try authManager.getAuthId()
                
                let avatar = Avatar(
                    avatarId: UUID().uuidString,
                    name: avatarName,
                    character: character,
                    action: action,
                    location: location,
                    profileImageUrl: nil,
                    authodId: uid,
                    dateCreated: .now,
                    viewCount: 0
                )
                
                try await avatarManager.createAvatar(
                    avatar: avatar,
                    image: generatedImage
                )
                
                dismiss()
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
            
            isSaving = false
        }
    }
}

#Preview {
    CreateAvatarView()
        .environment(AIManager(aiService: MockAIService()))
        .environment(AuthManager(authService: MockAuthService()))
        .environment(AvatarManager(avatarService: MockAvatarService()))
}
