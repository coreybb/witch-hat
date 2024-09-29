import Foundation



// MARK: - Client Networking

/// A protocol that all client networking components must conform to. It ensures that a network client is available for performing network operations.
public protocol ClientNetworking {
    var networkClient: NetworkDataTransporting { get }
}

// MARK: - Network Requesting

/// A protocol for handling network requests. It includes the necessary encoder and decoder for encoding requests and decoding responses.
public protocol NetworkRequesting where Self: ClientNetworking {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    func request<ResponseObject: Decodable, RequestObject: Encodable>(_ endpoint: Endpoint, body: RequestObject?) async throws -> ResponseObject
}

public extension NetworkRequesting {
    
    /// Makes a network request to the specified endpoint with an optional request body, and decodes the response into the specified response object type.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to which the request will be made.
    ///   - body: An optional request body that conforms to `Encodable`.
    /// - Returns: A response object that conforms to `Decodable`.
    /// - Throws: Throws an error if the request fails or if decoding the response fails.
    func request<ResponseObject: Decodable, RequestObject: Encodable>(_ endpoint: Endpoint, body: RequestObject?) async throws -> ResponseObject {
        
        var request = endpoint.urlRequest(using: (body != nil) ? encoder : nil)
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await networkClient.sendRequest(request)
        guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode.isOK else {
            throw NetworkError.invalidResponse
        }

        do {
            return try decoder.decode(ResponseObject.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}

// MARK: - Network Uploading

/// A protocol for handling network uploads. It includes the necessary encoder for encoding the upload data.
public protocol NetworkUploading where Self: ClientNetworking {
    var encoder: JSONEncoder { get }
    func upload<RequestObject: Encodable>(_ endpoint: Endpoint, body: RequestObject?) async throws -> Progress
}

public extension NetworkUploading {
    
    /// Uploads data to the specified endpoint with an optional request body.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to which the data will be uploaded.
    ///   - body: An optional request body that conforms to `Encodable`.
    /// - Returns: A `Progress` object representing the progress of the upload.
    /// - Throws: Throws an error if the upload fails.
    func upload<RequestObject: Encodable>(_ endpoint: Endpoint, body: RequestObject?) async throws -> Progress {
        var request = endpoint.urlRequest(using: (body != nil) ? encoder : nil)
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (progress, response) = try await networkClient.upload(request, from: try encoder.encode(body))
        guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode.isOK else {
            throw NetworkError.invalidResponse
        }

        return progress
    }
}

// MARK: - Network Downloading

/// A protocol for handling network downloads. It includes the necessary encoder for encoding any data to be sent with the download request.
public protocol NetworkDownloading where Self: ClientNetworking {
    var encoder: JSONEncoder { get }
    func download<RequestObject: Encodable>(_ endpoint: Endpoint, body: RequestObject?) async throws -> URL
}

public extension NetworkDownloading {
    
    /// Downloads data from the specified endpoint with an optional request body.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint from which the data will be downloaded.
    ///   - body: An optional request body that conforms to `Encodable`.
    /// - Returns: A `URL` object representing the location of the downloaded data.
    /// - Throws: Throws an error if the download fails.
    func download<RequestObject: Encodable>(_ endpoint: Endpoint, body: RequestObject?) async throws -> URL {
        var request = endpoint.urlRequest(using: (body != nil) ? encoder : nil)
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (url, response) = try await networkClient.download(request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode.isOK else {
            throw NetworkError.invalidResponse
        }

        return url
    }
}

// MARK: - Networking

/// A protocol that combines all networking capabilities, ensuring that client networking, requesting, uploading, and downloading are all supported.
public protocol FullNetworking: ClientNetworking, NetworkRequesting, NetworkUploading, NetworkDownloading { }
