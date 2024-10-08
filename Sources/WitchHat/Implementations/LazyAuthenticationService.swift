import Foundation

public actor LazyAuthenticationService<T: TokenRefreshEndpoint>: AuthenticationServicing {

    public let decoder: JSONDecoder
    public let encoder: JSONEncoder
    public let networkClient: NetworkDataTransporting
    private var token: String?
    private var tokenExpiration: Date?
    private let tokenRefreshEndpoint: T
    
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
    

    public func validToken() async throws -> String {
        if let token,
           let tokenExpiration,
           tokenExpiration > Date() {
            return token
        }
        try await refreshToken()
        guard let token else {
            throw AuthenticationError.tokenRefreshFailed
        }
        return token
    }

    
    public func refreshToken() async throws {
        let response: T.TokenResponse = try await request(tokenRefreshEndpoint)
        guard let newToken = tokenRefreshEndpoint.extractToken(from: response) else {
            throw AuthenticationError.tokenRefreshFailed
        }
        token = newToken
        tokenExpiration = (Date().addingTimeInterval(tokenRefreshEndpoint.tokenLifetime))
    }
}
