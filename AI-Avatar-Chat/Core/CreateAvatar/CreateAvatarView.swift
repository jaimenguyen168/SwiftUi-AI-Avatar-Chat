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
    
    @Environment(LogManager.self) private var logManager
    
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
            .screenAppearAnalytics(name: "CreateAvatarView")
        }
    }
}

// MARK: Views Section
private extension CreateAvatarView {
    var backButton: some View {
        Image(systemName: "xmark")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.red)
            .customButton {
                onBackButtonPress()
            }
    }
    
    var nameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("Name Your Avatar")
        }
    }
    
    var attributesSection: some View {
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
    
    var imageSection: some View {
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
    
    var saveSection: some View {
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
}

// MARK: Additional Data Section
private extension CreateAvatarView {
    enum Event: LoggableEvent {
        case backButtonPressed
        case generateImageStart
        case generateImageSuccess(builder: AvatarDescriptionBuilder)
        case generateImageFailed(error: Error)
        case saveAvatarStart
        case saveAvatarSuccess(avatar: Avatar)
        case saveAvatarFailed(error: Error)
        
        var eventName: String {
            switch self {
            case .backButtonPressed:     "CreateAvatarView_BackButton_Pressed"
            case .generateImageStart:    "CreateAvatarView_GenerateImage_Start"
            case .generateImageSuccess:  "CreateAvatarView_GenerateImage_Success"
            case .generateImageFailed:   "CreateAvatarView_GenerateImage_Failed"
            case .saveAvatarStart:       "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess:     "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFailed:      "CreateAvatarView_SaveAvatar_Failed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .generateImageSuccess(builder: let builder):
                return builder.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .saveAvatarFailed(error: let error), .generateImageFailed(error: let error):
                return error.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .generateImageFailed: .severe
            case .saveAvatarFailed: .warning
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension CreateAvatarView {
    func onBackButtonPress() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    
    func onGenerateImagePress() {
        isGenerating = true
        logManager.trackEvent(event: Event.generateImageStart)
        
        Task {
            do {
                let builder = AvatarDescriptionBuilder(
                    character: character,
                    action: action,
                    location: location
                )
                let prompt = builder.description
                
                generatedImage = try await aiManager.generateImage(prompt: prompt)
                logManager.trackEvent(event: Event.generateImageSuccess(builder: builder))
            } catch {
                showAlert = AppAlert(error: error)
                logManager.trackEvent(event: Event.generateImageFailed(error: error))
            }
            
            isGenerating = false
        }
    }
    
    func onSavePress() {
        guard let generatedImage else { return }
        isSaving = true
        logManager.trackEvent(event: Event.saveAvatarStart)
        
        Task {
            do {
                try TextValidationHelper.validateText(text: avatarName, minimumLength: 4)
                let uid = try authManager.getAuthId()
                
                let avatar = Avatar.newAvatar(
                    name: avatarName,
                    character: character,
                    action: action,
                    location: location,
                    authorId: uid
                )
                
                try await avatarManager.createAvatar(
                    avatar: avatar,
                    image: generatedImage
                )
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.saveAvatarFailed(error: error))
                showAlert = .init(error: error)
            }
            
            isSaving = false
        }
    }
}

#Preview {
    CreateAvatarView()
        .previewAllEnvironments()
}
