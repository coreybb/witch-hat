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
    var method: HTTPMethod { get }
    var headers: [HTTPHeader]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Body? { get }
    var requiresAuthentication: Bool { get }
    var url: URL { get }
    func urlRequest(using encoder: JSONEncoder?) -> URLRequest
}



//  MARK: - Default Implementation
public extension Endpoint {
    
    var path: String? { nil }
    
    var method: HTTPMethod { .get }

    var requiresAuthentication: Bool { false }
    
    var queryItems: [URLQueryItem]? { nil }
    
    var body: Body? { nil }

    var headers: [HTTPHeader]? { nil }
    
    var url: URL {
        
        var components = {
            (path == nil) ? nil :
            URLComponents(
                url: baseURL.appendingPathComponent(path!),
                resolvingAgainstBaseURL: true
            )
        }()
        
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


public enum EndpointError: Error {
    case invalidURLComponents
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
