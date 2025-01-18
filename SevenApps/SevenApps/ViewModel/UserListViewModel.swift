//
//  UserListViewModel.swift
//  SevenApps
//
//  Created by Metin on 18.01.2025.
//

import Foundation

class UserListViewModel {
    private let repository: UserRepositoryProtocol
    private var users: [User] = []
    
    var numberOfUsers: Int {
        return users.count
    }
    
    init(repository: UserRepositoryProtocol = UserRepository()) {
        self.repository = repository
    }
    
    func user(at index: Int) -> User {
        return users[index]
    }
    
    func fetchUsers() async throws {
        users = try await repository.getUsers()
    }
}

