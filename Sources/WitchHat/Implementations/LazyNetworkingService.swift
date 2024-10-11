import Foundation


/// An actor that provides basic networking capabilities.
/// Conforms to `ClientNetworking`, `JSONCoding`, and `NetworkRequesting` protocols.
public actor LazyNetworkingService: ClientNetworking, JSONCoding, NetworkRequesting, NetworkStatusProviding {
    
    /// A basic network monitor that publishes changes to the device's network connection.
    public let networkMonitor: NetworkMonitoring
    
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
    ///   - networkMonitor: The type implementing `NetworkMonitoring`. Defaults to a basic implementation.
    public init(
        networkClient: any NetworkDataTransporting,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
        networkMonitor: any NetworkMonitoring = NetworkMonitor()
    ) {
        self.networkClient = networkClient
        self.encoder = encoder
        self.decoder = decoder
        self.networkMonitor = networkMonitor
    }
}
