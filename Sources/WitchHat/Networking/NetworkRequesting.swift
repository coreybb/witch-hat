import Foundation
import UIKit.UIImage

public struct EmptyResponse: Decodable {}


/// A protocol for handling network requests. It includes the necessary encoder and decoder for encoding requests and decoding responses.
public protocol NetworkRequesting where Self: ClientNetworking & JSONCoding {
    func request<ResponseObject: Decodable>(_ endpoint: any Endpoint) async throws -> ResponseObject
    func requestImage(_ endpoint: any Endpoint) async throws -> UIImage
}


public extension NetworkRequesting {
    
    /// Makes a network request to the specified endpoint with an optional request body, and decodes the response into the specified response object type.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to which the request will be made..
    /// - Returns: A response object that conforms to `Decodable`.
    /// - Throws: Throws an error if the request fails or if decoding the response fails.
    func request<ResponseObject: Decodable>(_ endpoint: any Endpoint) async throws -> ResponseObject {
        try await prepareAndSendRequest(endpoint).decode(using: decoder)
    }

    
    func requestImage(_ endpoint: any Endpoint) async throws -> UIImage {
        try await prepareAndSendRequest(endpoint).decodeAsImage()
    }
    
    
    private func prepareAndSendRequest(_ endpoint: any Endpoint) async throws -> Data {
        
        var request = endpoint.urlRequest(using: encoder)
        
        if endpoint.requiresAuthentication,
           let authenticator = self as? AuthenticationServicing {
            try await authenticator.addAuthenticationHeader(to: &request)
        }
        
        let (data, response) = try await networkClient.sendRequest(request)
        try response.isOK()
        return data
    }
}


fileprivate extension Data {
    
    func decode<T: Decodable>(using decoder: JSONDecoder) throws -> T {
        if self.isEmpty {
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            } else {
                throw NetworkError.unexpectedEmptyResponse
            }
        } else {
            return try decoder.decode(T.self, from: self)
        }
    }
    
    
    func decodeAsImage() throws -> UIImage {
        guard let image = UIImage(data: self) else {
            throw NetworkError.decodingError
        }
        return image
    }
}


fileprivate extension URLResponse {
    
    func isOK() throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode.isOK else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}


fileprivate typealias StatusCode = Int


fileprivate extension StatusCode {
    var isOK: Bool {
        (200...299).contains(self)
    }
}
