//
//  NetworkService.swift
//  SevenApps
//
//  Created by Alex
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingError
    case serverError(Error)
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.noData, .noData):
            return true
        case (.decodingError, .decodingError):
            return true
        case (.serverError(let lhsError as NSError), .serverError(let rhsError as NSError)):
            return lhsError.domain == rhsError.domain && lhsError.code == rhsError.code
        default:
            return false
        }
    }
}

protocol NetworkServiceProtocol {
    func fetchUsers() async throws -> [User]
    func fetchUser(id: Int) async throws -> User
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL: String
    private let session: URLSession
    
    init(baseURL: String = "https://jsonplaceholder.typicode.com",
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func fetchUsers() async throws -> [User] {
        let urlString = "\(baseURL)/users"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(NSError(domain: "Unknown", code: 0, userInfo: nil))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(NSError(domain: "Unknown", code: httpResponse.statusCode, userInfo: nil))
        }
        
        do {
            let users = try JSONDecoder().decode([User].self, from: data)
            return users
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchUser(id: Int) async throws -> User {
        let urlString = "\(baseURL)/users/\(id)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(NSError(domain: "Unknown", code: 0, userInfo: nil))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(NSError(domain: "Unknown", code: httpResponse.statusCode, userInfo: nil))
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            throw NetworkError.decodingError
        }
    }
}
