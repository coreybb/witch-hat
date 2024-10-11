import Foundation


/// An actor that provides networking capabilities with built-in authentication support.
/// This service combines a base networking service and an authentication service
/// to handle authenticated network requests.
public actor LazyAuthenticatedNetworkingService<T: TokenRefreshEndpoint>: NetworkRequesting, JSONCoding, NetworkStatusProviding {
    
    /// The JSON encoder used for encoding request bodies.
    public let encoder: JSONEncoder
    
    /// The JSON decoder used for decoding response bodies.
    public let decoder: JSONDecoder
    
    /// The network client responsible for sending requests (e.g., `URLSession`).
    public let networkClient: NetworkDataTransporting
    
    /// The base networking service used for non-authenticated requests.
    public let baseService: LazyNetworkingService
    
    /// The authentication service responsible for handling token management.
    public let authService: LazyAuthenticationService<T>
    
    /// A basic network monitor that publishes changes to the device's network connection.
    public let networkMonitor: any NetworkMonitoring

    
    /// Initializes a new instance of `LazyAuthenticatedNetworkingService`.
    ///
    /// - Parameters:
    ///   - networkClient: The network client used to send requests.
    ///   - tokenRefreshEndpoint: The endpoint used to refresh authentication tokens.
    ///   - encoder: A JSON encoder for encoding request bodies. Defaults to a new `JSONEncoder`.
    ///   - decoder: A JSON decoder for decoding response bodies. Defaults to a new `JSONDecoder`.
    ///   - networkMonitor: The type implementing `NetworkMonitoring`. Defaults to a basic implementation.
    public init(
        networkClient: any NetworkDataTransporting,
        tokenRefreshEndpoint: T,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
        networkMonitor: any NetworkMonitoring = NetworkMonitor()
    ) {
        self.networkClient = networkClient
        self.encoder = encoder
        self.decoder = decoder
        self.networkMonitor = networkMonitor
        self.baseService = LazyNetworkingService(
            networkClient: networkClient,
            encoder: encoder,
            decoder: decoder,
            networkMonitor: networkMonitor
        )
        self.authService = LazyAuthenticationService(
            networkClient: networkClient,
            tokenRefreshEndpoint: tokenRefreshEndpoint,
            decoder: decoder,
            encoder: encoder,
            networkMonitor: networkMonitor
        )
    }
}
