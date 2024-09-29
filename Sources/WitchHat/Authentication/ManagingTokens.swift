import Foundation


public protocol ManagingTokens: AnyObject {
    func getToken() async -> String?
    func setToken(_ token: String?) async
    func getTokenExpiration() async -> Date?
    func setTokenExpiration(_ expiration: Date?) async
    func validToken() async throws -> String
    func refreshedToken() async throws -> String
    func getTokenRefreshEndpoint() async -> TokenRefreshEndpoint
}


public extension ManagingTokens where Self: ClientNetworking & AuthenticatingRequests {
    
    func validToken() async throws -> String {
        
        if let token = await getToken(),
            let expiration = await getTokenExpiration(),
            expiration > Date() {
            return token
        }
        return try await refreshedToken()
    }
    
    
    func refreshedToken() async throws -> String {
        
        let endpoint = await getTokenRefreshEndpoint()
        // TODO: - Figure out how we might pass any required request data with concrete encoder
        let (data, response) = try await networkClient.sendRequest(endpoint.urlRequest(using: nil))
        
        guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode.isOK else {
            throw NetworkError.invalidResponse
        }
        
        // TODO: - Provide a mechanism to decode different object types to extract token?
        guard let newToken = String(data: data, encoding: .utf8) else {
            throw NetworkError.invalidResponse
        }
        
        await setToken(newToken)
        await setTokenExpiration(endpoint.expiration)
        
        return newToken
    }
}
