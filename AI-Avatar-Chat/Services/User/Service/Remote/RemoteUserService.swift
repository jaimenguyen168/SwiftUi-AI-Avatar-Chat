//
//  RemoteUserService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/17/25.
//
import SwiftUI

protocol RemoteUserService: Sendable {
    func saveUser(user: AppUser) async throws
    func markOnboardingComplete(userId: String, profileColorHex: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<AppUser, Error>
    func deleteUser(userId: String) async throws
}
