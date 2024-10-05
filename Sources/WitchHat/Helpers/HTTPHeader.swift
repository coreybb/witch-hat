import Foundation

public struct HTTPHeader: Sendable {

    let name: Name
    let value: String
    
    public static func bearerToken(_ token: String) -> HTTPHeader {
        HTTPHeader(name: .authorization, value: "Bearer \(token)")
    }
    
    
    
    
    public init(name: Name, value: String) {
        self.name = name
        self.value = value
    }
    
    
    public init(name: Name, contentType: Value.ContentType) {
        self.name = name
        self.value = contentType.rawValue
    }
    
    
    public init(name: Name, accept: Value.Accept) {
        self.name = name
        self.value = accept.rawValue
    }
}




public extension HTTPHeader {
    
    enum Name: String, Sendable {
        case contentType = "Content-Type"
        case accept = "Accept"
        case authorization = "Authorization"
        case userAgent = "User-Agent"
    }
    
    
    enum Value {
        public enum ContentType: String {
            case applicationJSON = "application/json"
            case applicationXWWWFormURLEncoded = "application/x-www-form-urlencoded"
            case textPlain = "text/plain"
        }
        
        public enum Accept: String {
            case applicationJSON = "application/json"
            case textHTML = "text/html"
            
        }
    }
 }



extension URLRequest {
    
    mutating func addHeader(_ header: HTTPHeader) {
        addValue(header.value, forHTTPHeaderField: header.name.rawValue)
    }
}
