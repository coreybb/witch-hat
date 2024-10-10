import Foundation

/// An actor that manages authentication tasks, such as retrieving and refreshing tokens.
/// Conforms to the `AuthenticationServicing` protocol to provide authentication capabilities.
public actor LazyAuthenticationService<T: TokenRefreshEndpoint>: AuthenticationServicing {
    
    /// The type of the token refresh endpoint.
    public typealias RefreshEndpoint = T
    
    /// The JSON decoder used for decoding responses.
    public let decoder: JSONDecoder
    
    /// The JSON encoder used for encoding request bodies.
    public let encoder: JSONEncoder
    
    /// The network client responsible for sending requests (e.g., `URLSession`).
    public let networkClient: NetworkDataTransporting
    
    /// The endpoint used to refresh authentication tokens.
    public let tokenRefreshEndpoint: T
    
    /// The current authentication token.
    public var token: String?
    
    /// The expiration date of the current authentication token.
    public var tokenExpiration: Date?
    
    
    /// Initializes a new instance of `LazyAuthenticationService`.
    ///
    /// - Parameters:
    ///   - networkClient: The network client used to send requests.
    ///   - tokenRefreshEndpoint: The endpoint used to refresh authentication tokens.
    ///   - decoder: A JSON decoder for decoding responses. Defaults to a new `JSONDecoder`.
    ///   - encoder: A JSON encoder for encoding request bodies. Defaults to a new `JSONEncoder`.
    public init(
        networkClient: NetworkDataTransporting,
        tokenRefreshEndpoint: T,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.networkClient = networkClient
        self.tokenRefreshEndpoint = tokenRefreshEndpoint
        self.decoder = decoder
        self.encoder = encoder
    }
    
    
    /// Retrieves the current authentication token.
    ///
    /// - Returns: The current token as a `String`, or `nil` if not set.
    public func getToken() -> String? { token }
    
    /// Retrieves the expiration date of the current token.
    ///
    /// - Returns: The expiration `Date` of the token, or `nil` if not set.
    public func getTokenExpiration() -> Date? { tokenExpiration }
    
    /// Sets the authentication token.
    ///
    /// - Parameter newToken: The new token to set.
    public func setToken(_ newToken: String?) {
        token = newToken
    }
    
    /// Sets the expiration date for the current token.
    ///
    /// - Parameter date: The new expiration date to set.
    public func setTokenExpiration(_ date: Date?) {
        tokenExpiration = date
    }
}
