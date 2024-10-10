import Foundation

/// A protocol that defines the requirements for an endpoint that supports token refresh operations.
/// Types conforming to this protocol should specify how the token is extracted from the response and
/// the lifetime of the token.
public protocol TokenRefreshEndpoint: Endpoint {
    
    /// The type of response returned when a token refresh request is made.
    /// This type must conform to `Decodable` and `Sendable`.
    associatedtype TokenResponse: Decodable & Sendable
    
    /// The lifetime of the token in seconds. Used to determine when the token should be refreshed.
    var tokenLifetime: TimeInterval? { get }
    
    /// Extracts the token from the response received after a token refresh request.
    /// - Parameter response: The decoded response object containing the new token.
    /// - Returns: A `String` representing the extracted token, or `nil` if extraction fails.
    func extractToken(from response: TokenResponse) -> String?
    
    
    func extractTokenExpirationDate(from response: TokenResponse) -> Date?
}
