public struct HTTPHeader {

    let name: Name
    let value: String
    
    
    
    
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
    
    enum Name: String {
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




public extension Array where Element == HTTPHeader {

    func toDictionary() -> [String: String] {
        Dictionary(
            uniqueKeysWithValues: self.map {
                ($0.name.rawValue, $0.value)
            }
        )
    }
}
