import Foundation


/// An actor that provides basic networking capabilities.
/// Conforms to `ClientNetworking`, `JSONCoding`, and `NetworkRequesting` protocols.
/// Optionally accepts an authentication service to handle authenticated requests.
public actor LazyNetworkingService: ClientNetworking, JSONCoding, NetworkRequesting {
    
    /// The network client responsible for sending requests (e.g., `URLSession`).
    public let networkClient: any NetworkDataTransporting
    
    /// The JSON encoder used for encoding request bodies.
    public let encoder: JSONEncoder
    
    /// The JSON decoder used for decoding response bodies.
    public let decoder: JSONDecoder
    
    
    /// Initializes a new instance of `LazyNetworkingService`.
    ///
    /// - Parameters:
    ///   - networkClient: The network client used to send requests.
    ///   - encoder: A JSON encoder for encoding request bodies. Defaults to a new `JSONEncoder`.
    ///   - decoder: A JSON decoder for decoding response bodies. Defaults to a new `JSONDecoder`.
    public init(
        networkClient: any NetworkDataTransporting,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
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
 - Tests
 */
