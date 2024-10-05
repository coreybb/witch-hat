import Foundation

public protocol Endpoint: Sendable {
    associatedtype Body: Encodable
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [HTTPHeader] { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Body? { get }
    var requiresAuthentication: Bool { get }
    var url: URL { get }
    func urlRequest(using encoder: JSONEncoder?) -> URLRequest
}



//  MARK: - Default Implementation
extension Endpoint {
    
    var url: URL {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: true
        )
        
        components?.queryItems = queryItems
        guard let url = components?.url else {
            preconditionFailure("Invalid URL components: \(String(describing: components))")
        }
        
        return url
    }

    func urlRequest(using encoder: JSONEncoder?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers.toDictionary()
        
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
