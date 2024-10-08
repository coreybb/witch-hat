import Foundation

public protocol RequestAuthenticating {
    var authService: AuthenticationServicing { get }
}

public protocol AuthenticationServicing: NetworkRequesting {
    
    func validToken() async throws -> String
    func refreshToken() async throws
    func addAuthenticationHeader(to request: inout URLRequest) async throws
}


public extension AuthenticationServicing {
    
    func addAuthenticationHeader(to request: inout URLRequest) async throws {
        request.addHeader(.bearerToken(try await validToken()))
    }
}


public protocol TokenRefreshEndpoint: Endpoint {
    associatedtype TokenResponse: Decodable & Sendable
    var tokenLifetime: TimeInterval { get }
    func extractToken(from response: TokenResponse) -> String?
}
