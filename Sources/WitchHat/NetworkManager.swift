import Foundation


// TODO: - Make actor?
public final class NetworkManager: RequestProtocol {
    

    private let networkMonitor: NetworkMonitor
    private let networkClient: NetworkClientProtocol
    private let authService: AuthenticationProtocol
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    
    public init(
        networkClient: NetworkClientProtocol,
        networkMonitor: NetworkMonitor,
        authProtocol: AuthenticationProtocol
    ) {
        self.networkMonitor = networkMonitor
        self.networkClient = networkClient
        self.authService = authProtocol
    }
    
    
    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        
        let encoderToUse = endpoint.body != nil ? encoder : nil
        var request = endpoint.urlRequest(using: encoderToUse)
        
        if endpoint.requiresAuthentication {
            request = try await authService.authenticatedRequest(forRequest: request)
        }
        
        let (data, _) = try await networkClient.sendRequest(request)
        // TODO: - Handle response
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}

