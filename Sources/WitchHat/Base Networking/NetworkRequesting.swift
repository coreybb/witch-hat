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


//  MARK: - Default Implementation

public extension NetworkRequesting {
    
    /// Makes a network request to the specified endpoint and decodes the response into the specified response object type.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to which the request will be made..
    /// - Returns: A response object that conforms to `Decodable`.
    /// - Throws: Throws an error if the request fails or if decoding the response fails.
    func request<ResponseObject: Decodable>(_ endpoint: any Endpoint) async throws -> ResponseObject {
        try await prepareAndSendRequest(endpoint).decode(using: decoder)
    }


    /// Makes a network request to the specified endpoint and returns the raw data from the from the response.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to which the request will be made..
    /// - Returns: A response object that conforms to `Decodable`.
    /// - Throws: Throws an error if the request fails or if decoding the response fails.
    func requestData(_ endpoint: any Endpoint) async throws -> Data {
        try await prepareAndSendRequest(endpoint)
    }
}


//  MARK: - Private API

private extension NetworkRequesting {

    
    private func prepareAndSendRequest(_ endpoint: any Endpoint) async throws -> Data {
        let request = try await prepareRequest(for: endpoint)
        return try await performRequest(request, for: endpoint, remainingRetries: 1)
    }


    private func prepareRequest(for endpoint: any Endpoint) async throws -> URLRequest {
        var request = try endpoint.urlRequest(using: encoder)
        
        if endpoint.requiresAuthentication,
           let authenticator = self as? (any AuthenticationServicing) {
            try await authenticator.addAuthenticationHeader(to: &request)
        }
        
        return request
    }


    //  TODO: - Extract retry logic into discrete component (configurable retry count, exp backoff, jitter, custom status codes, etc.)
    private func performRequest(_ request: URLRequest, for endpoint: any Endpoint, remainingRetries: Int) async throws -> Data {
        try await attemptNetworkStatusCheck()
        let (data, response) = try await networkClient.sendRequest(request)

        if try await shouldRetry(response: response, for: endpoint, remainingRetries: remainingRetries) {
            return try await performRetry(for: request, for: endpoint, remainingRetries: remainingRetries)
        }
        
        try response.validate()
        return data
    }
    
    
    private func attemptNetworkStatusCheck() async throws {
        if let networkStatusProvider = self as? NetworkStatusProviding,
           !(await networkStatusProvider.isConnectedToNetwork()) {
            throw NetworkError.noInternetConnection
        }
    }
    
    
    private func shouldRetry(response: URLResponse, for endpoint: any Endpoint, remainingRetries: Int) async throws -> Bool {
        guard remainingRetries > 0,
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode.isUnauthorized,
              endpoint.requiresAuthentication else {
            return false
        }
        return true
    }
    
    
    private func performRetry(for request: URLRequest, for endpoint: any Endpoint, remainingRetries: Int) async throws -> Data {
        var newRequest = request
        try await attemptAuthentication(for: &newRequest)
        return try await performRequest(newRequest, for: endpoint, remainingRetries: remainingRetries - 1)
    }
    
    
    private func attemptAuthentication(for request: inout URLRequest) async throws {
        if let authenticator = self as? (any AuthenticationServicing) {
            try await authenticator.refreshToken()
            try await authenticator.addAuthenticationHeader(to: &request)
        }
    }
}
