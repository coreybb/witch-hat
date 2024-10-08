import Foundation

public struct LazyEndpoint: Endpoint {
    public let baseURL: URL
    
    public init(url: URL) {
        baseURL = url
    }
}
