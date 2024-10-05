import Foundation

open class LazyNetworkingService: ClientNetworking, JSONCoding, NetworkRequesting, RequestAuthenticating {
    
    public let authService: any AuthenticationServicing
    public let networkClient: any NetworkDataTransporting
    public let encoder: JSONEncoder
    public let decoder: JSONDecoder
    
    
    public init(
        networkClient: any NetworkDataTransporting,
        encoder: JSONEncoder,
        decoder: JSONDecoder,
        authService: any AuthenticationServicing
    ) {
        self.networkClient = networkClient
        self.encoder = encoder
        self.decoder = decoder
        self.authService = authService
    }
}

//---------
// TODO: -
//---------
/*
 - Network monitoring
 - Logging
 - Retries
 - Caching
 */
