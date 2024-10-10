import Foundation

protocol RetryManaging {
    func shouldRetry(request: URLRequest, response: URLResponse?, error: Error?, attempts: Int) async -> Bool
    func retryDelay(for attempts: Int) -> TimeInterval
}
