//
//  SevenAppsTests.swift
//  SevenAppsTests
//
//  Created by Metin on 18.01.2025.
//

import XCTest
@testable import SevenApps

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

class SevenAppsTests: XCTestCase {
    var networkService: NetworkService!
    var session: URLSession!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        
        networkService = NetworkService(session: session)
    }
    
    override func tearDown() {
        networkService = nil
        session = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testFetchUsers_Success() async throws {
        // Given
        let jsonString = "["
        + "{"
        + "\"id\": 1,"
        + "\"name\": \"Test User\","
        + "\"username\": \"testuser\","
        + "\"email\": \"test@example.com\","
        + "\"phone\": \"1-234-567-8900\","
        + "\"website\": \"testuser.com\","
        + "\"address\": {"
        + "    \"street\": \"Test Street\","
        + "    \"suite\": \"Suite 1\","
        + "    \"city\": \"Test City\","
        + "    \"zipcode\": \"12345\","
        + "    \"geo\": {"
        + "        \"lat\": \"0.0\","
        + "        \"lng\": \"0.0\""
        + "    }"
        + "},"
        + "\"company\": {"
        + "    \"name\": \"Test Company\","
        + "    \"catchPhrase\": \"Test Catch Phrase\","
        + "    \"bs\": \"Test BS\""
        + "}"
        + "}"
        + "]"
        let data = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, data)
        }
        
        // When
        let users = try await networkService.fetchUsers()
        
        // Then
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].id, 1)
        XCTAssertEqual(users[0].name, "Test User")
        XCTAssertEqual(users[0].username, "testuser")
        XCTAssertEqual(users[0].email, "test@example.com")
    }
    
    func testFetchUser_Success() async throws {
        // Given
        let jsonString = "{"
        + "\"id\": 1,"
        + "\"name\": \"Test User\","
        + "\"username\": \"testuser\","
        + "\"email\": \"test@example.com\","
        + "\"phone\": \"1-234-567-8900\","
        + "\"website\": \"testuser.com\","
        + "\"address\": {"
        + "    \"street\": \"Test Street\","
        + "    \"suite\": \"Suite 1\","
        + "    \"city\": \"Test City\","
        + "    \"zipcode\": \"12345\","
        + "    \"geo\": {"
        + "        \"lat\": \"0.0\","
        + "        \"lng\": \"0.0\""
        + "    }"
        + "},"
        + "\"company\": {"
        + "    \"name\": \"Test Company\","
        + "    \"catchPhrase\": \"Test Catch Phrase\","
        + "    \"bs\": \"Test BS\""
        + "}"
        + "}"
        let data = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
        
        // When
        let user = try await networkService.fetchUser(id: 1)
        
        // Then
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.username, "testuser")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.phone, "1-234-567-8900")
        XCTAssertEqual(user.website, "testuser.com")
        XCTAssertEqual(user.address.street, "Test Street")
        XCTAssertEqual(user.company.name, "Test Company")
    }
    
    func testFetchUsers_InvalidURL() async {
        // Given
        let invalidBaseURL = "||||://invalid" // Invalid URL with illegal characters
        networkService = NetworkService(baseURL: invalidBaseURL, session: session)
        
        // When/Then
        do {
            _ = try await networkService.fetchUsers()
            XCTFail("Expected invalidURL error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidURL)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetchUser_DecodingError() async {
        // Given
        let invalidData = "Invalid JSON".data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidData)
        }
        
        // When/Then
        do {
            _ = try await networkService.fetchUser(id: 1)
            XCTFail("Expected decodingError error")
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.decodingError)
        }
    }
    
    func testFetchUsers_ServerError() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        // When/Then
        do {
            _ = try await networkService.fetchUsers()
            XCTFail("Expected serverError")
        } catch NetworkError.serverError(let error as NSError) {
            XCTAssertEqual(error.code, 500)
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}
