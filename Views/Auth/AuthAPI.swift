//
//  AuthAPI.swift
//  FITGET
//

import Foundation

struct AuthAPIConfig {
    static let baseURL = BackendConfig.baseURL
    static let apiKey  = BackendConfig.publicApiKey
}

struct AuthUserDTO: Codable {
    let id: String
    let email: String?
    let fullName: String?
    let isGuest: Bool
    let age: Int?
    let height: Double?
    let weight: Double?
    let gender: String?
}

struct AuthResponseDTO: Codable {
    let accessToken: String
    let user: AuthUserDTO
}

enum AuthAPI {
    
    static func login(email: String, password: String) async throws -> AuthResponseDTO {
        let url = AuthAPIConfig.baseURL.appendingPathComponent("/auth/login")
        let body = [
            "email": email,
            "password": password
        ]
        return try await request(url: url, body: body)
    }
    
    static func register(
        name: String,
        email: String,
        password: String,
        guestId: String?,
        age: Int?,
        height: Double?,
        weight: Double?,
        gender: String?
    ) async throws -> AuthResponseDTO {
        let url = AuthAPIConfig.baseURL.appendingPathComponent("/auth/register")
        
        var body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]
        
        if let guestId = guestId { body["guest_id"] = guestId }
        if let age = age { body["age"] = age }
        if let height = height { body["height"] = height }
        if let weight = weight { body["weight"] = weight }
        if let gender = gender { body["gender"] = gender }
        
        return try await request(url: url, body: body)
    }
    
    static func oauthSignIn(
        provider: String,
        token: String
    ) async throws -> AuthResponseDTO {
        let url = AuthAPIConfig.baseURL.appendingPathComponent("/auth/oauth")
        let body: [String: Any] = [
            "provider": provider,
            "token": token
        ]
        return try await request(url: url, body: body)
    }
    
    // MARK: - Private
    
    private static func request(
        url: URL,
        body: [String: Any]
    ) async throws -> AuthResponseDTO {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !AuthAPIConfig.apiKey.isEmpty {
            request.setValue(AuthAPIConfig.apiKey, forHTTPHeaderField: "x-api-key")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(AuthResponseDTO.self, from: data)
    }
}
