import Foundation


//  MARK: - Token Refresh Endpoint
public protocol TokenRefreshEndpoint: Endpoint {
    var expiration: Date { get }
}


public protocol AuthenticationServicing: NetworkRequesting, AuthenticatingRequests, ManagingTokens  {
    func getToken() async -> String?
    func setToken(_ token: String?) async
    func getTokenExpiration() async -> Date?
    func setTokenExpiration(_ expiration: Date?) async
    func validToken() async throws -> String
    func refreshedToken() async throws -> String
}


//  MARK: - Authentication Service
public actor AuthenticationService: AuthenticationServicing {

    
    //  MARK: - Public Properties
    public let decoder: JSONDecoder = JSONDecoder()
    public let encoder: JSONEncoder = JSONEncoder()
    public let networkClient: NetworkDataTransporting
    private var _token: String?
    private var _tokenExpiration: Date?
    private let tokenRefreshEndpoint: TokenRefreshEndpoint

    
    //  MARK: - Init
    public init(
        networkClient: NetworkDataTransporting,
        tokenRefreshEndpoint: TokenRefreshEndpoint
    ) {
        self.networkClient = networkClient
        self.tokenRefreshEndpoint = tokenRefreshEndpoint
    }

    
    //  MARK: - Public API
    public func getToken() async -> String? { _token }
    public func setToken(_ token: String?) async { _token = token }
    public func getTokenExpiration() async -> Date? { _tokenExpiration }
    public func setTokenExpiration(_ expiration: Date?) async { _tokenExpiration = expiration }
    public func getTokenRefreshEndpoint() -> TokenRefreshEndpoint { tokenRefreshEndpoint }
    

}
