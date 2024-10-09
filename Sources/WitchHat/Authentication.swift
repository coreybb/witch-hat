import Foundation

public protocol RequestAuthenticating {
    var authService: AuthenticationServicing { get }
}

/// A protocol that defines the requirements for a service that manages authentication in network requests.
/// This includes fetching valid tokens, refreshing expired tokens, and adding authentication headers to requests.
public protocol AuthenticationServicing: NetworkRequesting {
    
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
}


/// A protocol that defines the requirements for an endpoint that supports token refresh operations.
/// Types conforming to this protocol should specify how the token is extracted from the response and
/// the lifetime of the token.
public protocol TokenRefreshEndpoint: Endpoint {
    
    /// The type of response returned when a token refresh request is made.
    /// This type must conform to `Decodable` and `Sendable`.
    associatedtype TokenResponse: Decodable & Sendable
    
    /// The lifetime of the token in seconds. Used to determine when the token should be refreshed.
    var tokenLifetime: TimeInterval { get }
    
    /// Extracts the token from the response received after a token refresh request.
    /// - Parameter response: The decoded response object containing the new token.
    /// - Returns: A `String` representing the extracted token, or `nil` if extraction fails.
    func extractToken(from response: TokenResponse) -> String?
}
