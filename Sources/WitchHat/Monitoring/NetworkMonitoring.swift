import Network
import Combine


/// A protocol defining the requirements for network monitoring.
public protocol NetworkMonitoring: Sendable {
    /// Indicates whether the network is currently reachable.
    var isConnected: Bool { get async }
    
    /// Indicates whether the network connection is using cellular data.
    var connectionIsExpensive: Bool { get async }
    
    /// Indicates whether the system has constrained network data usage.
    var connectionIsConstrained: Bool { get async }

    /// Starts monitoring network changes.
    func startMonitoring() async

    /// Stops monitoring network changes.
    func stopMonitoring() async
}



/// An actor that monitors network connectivity using NWPathMonitor.
public actor NetworkMonitor: NetworkMonitoring {
    
    // MARK: - Public Properties

    /// Indicates whether the network is currently reachable.
    @Published public private(set) var isConnected = false
    
    /// Indicates whether the network connection is using cellular data.
    @Published public private(set) var connectionIsExpensive = false
    
    /// Indicates whether the system has constrained network data usage.
    @Published public private(set) var connectionIsConstrained = false

    
    // MARK: - Private Properties

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    private var activeMonitoringRequests: Int = 0

    
    // MARK: - Initialization

    /// Initializes a new instance of `NetworkMonitor`.
    ///
    /// - Parameter queue: The dispatch queue on which the monitor runs.
    ///                    Defaults to the shared `.global` queue with `.background` quality of service.
    public init(queue: DispatchQueue = DispatchQueue.global(qos: .background)) {
        self.monitor = NWPathMonitor()
        self.queue = queue
        
        Task {
            await startMonitoring()
        }
    }

    
    // MARK: - Public API

    /// Starts monitoring network changes.
    public func startMonitoring() async {
        activeMonitoringRequests += 1
        guard activeMonitoringRequests == 1 else { return }
        
        monitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.updateConnectionStatus(for: path)
            }
        }
        
        monitor.start(queue: queue)
    }

    
    /// Stops monitoring network changes.
    public func stopMonitoring() async {
        guard activeMonitoringRequests > 0 else { return }
        activeMonitoringRequests -= 1
        guard activeMonitoringRequests == 0 else { return }
        monitor.cancel()
        monitor.pathUpdateHandler = nil
    }
    

    
    // MARK: - Deinitialization

    deinit {
        monitor.cancel()
    }
}


// MARK: - Private API
private extension NetworkMonitor {
    
    private func updateConnectionStatus(for path: NWPath) {
        isConnected = path.status == .satisfied
        connectionIsExpensive = path.isExpensive
        connectionIsConstrained = path.isConstrained
    }
}
