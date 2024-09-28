import Foundation


public protocol NetworkClientProtocol: Sendable {
    func sendRequest(_ request: URLRequest) async throws -> (Data, URLResponse)
}
