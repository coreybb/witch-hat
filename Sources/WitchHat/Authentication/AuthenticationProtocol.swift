import Foundation

public protocol AuthenticationProtocol {
    func authenticatedRequest(forRequest request: URLRequest) async throws -> URLRequest
}
