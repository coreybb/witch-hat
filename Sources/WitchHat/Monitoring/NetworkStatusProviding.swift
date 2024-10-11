/// A protocol for services that provide network status information.
public protocol NetworkStatusProviding {
    /// The network monitor used to check connectivity.
    var networkMonitor: NetworkMonitoring { get }
    func isConnectedToNetwork() async -> Bool
    func networkConnectionIsExpensive() async -> Bool
    func networkConnectionIsConstrained() async -> Bool
}

public extension NetworkStatusProviding {
    
    func isConnectedToNetwork() async -> Bool {
        await networkMonitor.isConnected
    }
    
    func networkConnectionIsExpensive() async -> Bool {
        await networkMonitor.connectionIsExpensive
    }
    
    func networkConnectionIsConstrained() async -> Bool {
        await networkMonitor.connectionIsConstrained
    }
}
