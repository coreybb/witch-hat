import Foundation


extension URLSession: NetworkClientProtocol {
    
    public func sendRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}
