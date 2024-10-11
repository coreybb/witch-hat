import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case noInternetConnection
    case unauthorized
    case unexpectedEmptyResponse
    case unknown
}


enum AuthenticationError: Error {
    
    case tokenRefreshFailed
}


// TODO: -
/*
 - Mapped enumeration to status codes (as associated type on case .httpError)
 - Associated messages

 */
