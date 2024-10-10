import Foundation


/// A protocol that defines the requirements for a service that manages authentication in network requests.
/// This includes fetching valid tokens, refreshing expired tokens, and adding authentication headers to requests.
public protocol AuthenticationServicing: AnyObject, NetworkRequesting {
    
    associatedtype RefreshEndpoint: TokenRefreshEndpoint
    
    var tokenRefreshEndpoint: RefreshEndpoint { get }
    
    func getToken() async -> String?
    func setToken(_ token: String?) async
    func getTokenExpiration() async -> Date?
    func setTokenExpiration(_ date: Date?) async

    
    
    /// Provides a valid token for authentication, refreshing it if necessary.
    /// - Returns: A valid authentication token as a `String`.
    /// - Throws: An error if the token cannot be retrieved or refreshed.
    func validToken() async throws -> String
    
    /// Refreshes the authentication token. Typically called when a token is expired or invalid.
    /// - Throws: An error if the token cannot be refreshed.
    func refreshToken() async throws
    
    /// Adds an authentication header to a given `URLRequest`.
    /// - Parameter request: The `URLRequest` to which the authentication header should be added.
    /// - Throws: An error if the token cannot be retrieved or if adding the header fails.
    func addAuthenticationHeader(to request: inout URLRequest) async throws
}


public extension AuthenticationServicing {
    
    /// Default implementation for adding an authentication header to a request.
    /// Uses the `validToken` method to fetch the token and adds it as a Bearer token to the request.
    /// - Parameter request: The `URLRequest` to which the Bearer token header should be added.
    /// - Throws: An error if the token cannot be retrieved or if adding the header fails.
    func addAuthenticationHeader(to request: inout URLRequest) async throws {
        request.addHeader(.bearerToken(try await validToken()))
    }
    
    
    func validToken() async throws -> String {
        if let token = await getToken(),
           let expiration = await getTokenExpiration(),
           expiration > Date() {
            return token
        } else {
            try await refreshToken()
            guard let token = await getToken() else {
                throw AuthenticationError.tokenRefreshFailed
            }
            return token
        }
    }
    

    func refreshToken() async throws {
        let response: RefreshEndpoint.TokenResponse = try await request(tokenRefreshEndpoint)
        guard let newToken = tokenRefreshEndpoint.extractToken(from: response) else {
            throw AuthenticationError.tokenRefreshFailed
        }
        await setToken(newToken)
        let expirationDate = tokenRefreshEndpoint.extractTokenExpirationDate(from: response)
        await setTokenExpiration(expirationDate)
    }
}
