import Foundation


extension URLResponse {
    
    /// Checks if the HTTP response status code is in the 200-299 range.
    ///
    /// - Throws: A `NetworkError` if the response is not an HTTP response or if the status code is not in the 200-299 range.
    func validate() throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode.isOK else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}
