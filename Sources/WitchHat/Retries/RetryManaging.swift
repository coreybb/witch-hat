import Foundation

protocol RetryManaging {
    func shouldRetry(request: URLRequest, response: URLResponse?, error: Error?, attempts: Int) async -> Bool
    func retryDelay(for attempts: Int) -> TimeInterval
}


// TODO: -
/*
 - Configurable retry policies (max retries, backoff strategies)
 - Exponential backoff
*/
