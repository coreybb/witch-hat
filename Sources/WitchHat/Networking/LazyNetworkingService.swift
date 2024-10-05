import Foundation

open class LazyNetworkingService: ClientNetworking, JSONCoding, NetworkRequesting {
    
    public let networkClient: any NetworkDataTransporting
    public let encoder: JSONEncoder
    public let decoder: JSONDecoder
    
    
    public init(
        networkClient: any NetworkDataTransporting,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.networkClient = networkClient
        self.encoder = encoder
        self.decoder = decoder
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
