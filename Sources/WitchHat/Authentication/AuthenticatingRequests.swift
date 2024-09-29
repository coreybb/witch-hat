import Foundation


// MARK: - Authenticating Requests
public protocol AuthenticatingRequests {
    func authenticateRequest(_ request: URLRequest) async throws -> URLRequest
}


public extension AuthenticatingRequests where Self: ManagingTokens & NetworkRequesting {
    
    func authenticateRequest(_ request: URLRequest) async throws -> URLRequest {
        request.addingAuthorizationHeader(token: try await validToken())
    }
}




// MARK: - Helpers
fileprivate extension URLRequest {
    func addingAuthorizationHeader(token: String) -> URLRequest {
        var request = self
        request.addValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }
}
