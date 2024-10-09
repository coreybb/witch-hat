import Foundation

public protocol EndpointGroup {
    static var baseURL: URL { get }
}

public protocol GroupedEndpoint: Endpoint {
    associatedtype Group: EndpointGroup
}

public extension GroupedEndpoint {
    var baseURL: URL { Group.baseURL }
}

public protocol Endpoint: Sendable {
    associatedtype Body: Encodable = Never
    var baseURL: URL { get }
    var path: String? { get }
    var method: HTTPMethod { get set }
    var headers: [HTTPHeader]? { get set }
    var queryItems: [URLQueryItem]? { get set }
    var body: Body? { get set }
    var requiresAuthentication: Bool { get }
    var url: URL { get }
    func urlRequest(using encoder: JSONEncoder?) -> URLRequest
}


//  MARK: - Default Implementation
public extension Endpoint {
    
    var path: String? { nil }
    var method: HTTPMethod {
        get { .get }
        set { /* no-op, or handle if needed */ }
    }
    var headers: [HTTPHeader]? {
        get { nil }
        set { /* no-op, or handle if needed */ }
    }
    var queryItems: [URLQueryItem]? {
        get { nil }
        set { /* no-op, or handle if needed */ }
    }
    var body: Body? {
        get { nil }
        set { /* no-op, or handle if needed */ }
    }
    var requiresAuthentication: Bool { false }
    var url: URL {

        let baseComponents = path.map {
            URLComponents(
                url: baseURL.appendingPathComponent($0),
                resolvingAgainstBaseURL: true
            )
        } ?? URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        guard queryItems?.isEmpty == false else {
            return baseComponents?.url ?? baseURL
        }
        
        var components = baseComponents
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            preconditionFailure("Invalid URL components: \(String(describing: components))")
        }
        
        return url
    }

    
    func urlRequest(using encoder: JSONEncoder?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers?.toDictionary()
        
        if let body = body,
            let encoder = encoder {
            request.httpBody = try? encoder.encode(body)
        }
        
        return request
    }
}


fileprivate extension Array where Element == HTTPHeader {

    func toDictionary() -> [String: String] {
        Dictionary(
            uniqueKeysWithValues: self.map {
                ($0.name.rawValue, $0.value)
            }
        )
    }
}
