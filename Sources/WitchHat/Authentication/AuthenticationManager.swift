import Foundation
import Security


public final actor AuthenticationManager: AuthenticationProtocol {
    
    
    //  MARK: - Private Properties
    private let networkClient: NetworkClientProtocol
    
    // TODO: - expose?
    private var token: String?
    private var tokenExpirationDate: Date?
    
    
    
    //  MARK: - Init
    public init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    
    
    //  MARK: - Internal API
    public func authenticatedRequest(forRequest request: URLRequest) async throws -> URLRequest {
        var authenticatedRequest = request
        let token = try await validToken()
        authenticatedRequest.addValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }
    
    
    
    //  MARK: - Private API
    private func validToken() async throws -> String {
        
        if let token,
            let tokenExpirationDate,
            tokenExpirationDate > Date() {
            return token
        }
        
        return try await refreshedToken()
    }
    
    
    // TODO: - expose mechanism for implementing refresh logic
    private func refreshedToken() async throws -> String {
        
        let oneHour: TimeInterval = 3600

        let request = URLRequest(url: URL(string: "REFRESHER_URL")!)
        let (data, _) = try await networkClient.sendRequest(request)
        let newToken = String(data: data, encoding: .utf8) ?? ""
        token = newToken
        tokenExpirationDate = Date().addingTimeInterval(oneHour)
        return newToken
    }
}
