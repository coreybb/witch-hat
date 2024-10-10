import Foundation


/// A protocol that all client networking components must conform to. It ensures that a network client is available for performing network operations.
public protocol ClientNetworking {
    var networkClient: NetworkDataTransporting { get }
}


public protocol NetworkDataTransporting: Sendable {
    func sendRequest(_ request: URLRequest) async throws -> (Data, URLResponse)
}



//  MARK: - Default Implementation
extension URLSession: NetworkDataTransporting {
    
    public func sendRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await data(for: request)
        return (data, response)
    }
}
