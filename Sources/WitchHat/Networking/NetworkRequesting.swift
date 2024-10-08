import Foundation

/// Represents an empty response from an API call.
public struct EmptyResponse: Decodable {}


/// A protocol for handling network requests. It includes the necessary encoder and decoder for encoding requests and decoding responses.
public protocol NetworkRequesting where Self: ClientNetworking & JSONCoding {
    
    /// Makes a network request to the specified endpoint and decodes the response into the specified response object type.
    ///
    /// - Parameter endpoint: The endpoint to which the request will be made.
    /// - Returns: A response object that conforms to `Decodable`.
    /// - Throws: An error if the request fails or if decoding the response fails.
    func request<ResponseObject: Decodable>(_ endpoint: any Endpoint) async throws -> ResponseObject
    
    /// Makes a network request to the specified endpoint and returns the raw data response.
    ///
    /// - Parameter endpoint: The endpoint to which the request will be made.
    /// - Returns: The raw `Data` received from the network request.
    /// - Throws: An error if the request fails.
    func requestData(_ endpoint: any Endpoint) async throws -> Data
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



    func requestData(_ endpoint: any Endpoint) async throws -> Data {
        try await prepareAndSendRequest(endpoint)
    }
    
    
    /// Prepares and sends a network request to the specified endpoint.
    ///
    /// - Parameter endpoint: The endpoint to which the request will be made.
    /// - Returns: The raw `Data` received from the network request.
    /// - Throws: An error if preparing the request, authentication, or sending the request fails.
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
    
    /// Decodes the data into a specified `Decodable` type.
    ///
    /// - Parameter decoder: The `JSONDecoder` to use for decoding.
    /// - Returns: An instance of the specified `Decodable` type.
    /// - Throws: A `NetworkError` if the data is empty and the expected type is not `EmptyResponse`,
    ///           or a decoding error if the data cannot be decoded into the specified type.
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
}


fileprivate extension URLResponse {
    
    /// Checks if the HTTP response status code is in the 200-299 range.
    ///
    /// - Throws: A `NetworkError` if the response is not an HTTP response or if the status code is not in the 200-299 range.
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
