//
//  UserRepository.swift
//  SevenApps
//
//  Created by Alex
//

import Foundation

protocol UserRepositoryProtocol {
    func getUsers() async throws -> [User]
    func getUser(id: Int) async throws -> User
}

class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func getUsers() async throws -> [User] {
        return try await networkService.fetchUsers()
    }
    
    func getUser(id: Int) async throws -> User {
        return try await networkService.fetchUser(id: id)
    }
}
