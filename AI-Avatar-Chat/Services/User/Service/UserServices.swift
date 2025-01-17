//
//  UserServices.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/17/25.
//
import SwiftUI

protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistenceService { get }
}

struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistenceService
    
    init(user: AppUser? = nil) {
        self.remote = MockUserService(user: user)
        self.local = MockUserPersistence(user: user)
    }
}

struct ProductionUserServices: UserServices {
    let remote: RemoteUserService = FirebaseUserService()
    let local: LocalUserPersistenceService = FileManagerUserPersistence()
}
