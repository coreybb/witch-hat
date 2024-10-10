import Network
import Combine

// TODO: - make actor?
public final class NetworkMonitor: ObservableObject {
    
    
    //  MARK: - Internal Properties
    @MainActor @Published private(set) var isConnected = false
    
    
    
    //  MARK: - Private Properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "WITCH_HAT_NETWORK_MONITOR", qos: .background)
    
    
    
    //  MARK: - Init
    init() {
        setupMonitor()
    }
    
    
    
    //  MARK: - Private API
    private func setupMonitor() {
        // TODO: - Implement
        
        monitor.start(queue: queue)
    }
    
    
    
    //  MARK: - Deinit
    deinit {
        monitor.cancel()
    }
}
