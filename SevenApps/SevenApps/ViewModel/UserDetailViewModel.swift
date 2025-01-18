//
//  UserDetailViewModel.swift
//  SevenApps
//
//  Created by Metin on 18.01.2025.
//

import Foundation

class UserDetailViewModel {
    private let repository: UserRepositoryProtocol
    private let userId: Int
    private var user: User?
    
    init(repository: UserRepositoryProtocol = UserRepository(), userId: Int) {
        self.repository = repository
        self.userId = userId
    }
    
    func fetchUserDetails() async throws {
        user = try await repository.getUser(id: userId)
    }
    
    var userDetails: User? {
        return user
    }
}

