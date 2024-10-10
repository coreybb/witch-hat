import Foundation


/// A flexible endpoint type that conforms to the `Endpoint` protocol, allowing for dynamic API request configuration.
///
/// This struct is useful for cases where you want to create ad-hoc requests without needing
/// to define a custom `Endpoint` type each time. It offers default values for many parameters to make it
/// easier to use for common scenarios like `GET` requests.
public struct LazyEndpoint<Body: Encodable & Sendable>: Endpoint {
    
    public let baseURL: URL
    public var path: String?
    public var method: HTTPMethod
    public var headers: [HTTPHeader]?
    public var queryItems: [URLQueryItem]?
    public var body: Body?
}


public extension LazyEndpoint where Body == Never {
    
    /// - Parameters:
    ///   - url: The base URL for the endpoint. This is the root URL that the request will be sent to.
    ///   - path: The path component to be appended to the `baseURL`, such as `v1/users`.
    ///           Defaults to `nil`, meaning no additional path will be appended.
    ///   - method: The HTTP method for the request, such as `.get`, `.post`, or `.delete`.
    ///             Defaults to `.get` for simple `GET` requests without further configuration.
    ///   - headers: An array of `HTTPHeader` instances to include with the request, such as authorization or content type.
    ///              Defaults to `nil`, meaning no headers will be sent unless explicitly provided.
    ///   - queryItems: An array of `URLQueryItem` instances representing query parameters to be added to the request URL.
    ///                 Defaults to `nil`, meaning no query parameters will be included unless specified.
    ///   - body: The request body as an `Encodable & Sendable` object. Defaults to `nil`.
    init(
        url: URL,
        path: String? = nil,
        method: HTTPMethod = .get,
        headers: [HTTPHeader]? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Body? = nil
    ) {
        self.baseURL = url
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
    
    
    /// An initializer for `LazyEndpoint` when no request body is needed.
    /// - Parameters:
    ///   - url: The base URL for the endpoint. This is the root URL that the request will be sent to.
    ///   - path: The path component to be appended to the `baseURL`, such as `v1/users`.
    ///           Defaults to `nil`, meaning no additional path will be appended.
    ///   - method: The HTTP method for the request, such as `.get`, `.post`, or `.delete`.
    ///             Defaults to `.get` for simple `GET` requests without further configuration.
    ///   - headers: An array of `HTTPHeader` instances to include with the request, such as authorization or content type.
    ///              Defaults to `nil`, meaning no headers will be sent unless explicitly provided.
    ///   - queryItems: An array of `URLQueryItem` instances representing query parameters to be added to the request URL.
    ///                 Defaults to `nil`, meaning no query parameters will be included unless specified.
    init(
        url: URL,
        path: String? = nil,
        method: HTTPMethod = .get,
        headers: [HTTPHeader]? = nil,
        queryItems: [URLQueryItem]? = nil
    ) {
        self.init(
            url: url,
            path: path,
            method: method,
            headers: headers,
            queryItems: queryItems,
            body: nil
        )
    }
}

