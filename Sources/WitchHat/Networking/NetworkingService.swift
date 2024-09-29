import Foundation

public actor NetworkingService: FullNetworking {
    
    public let networkClient: any NetworkDataTransporting
    public let decoder = JSONDecoder()
    public let encoder = JSONEncoder()
    public let authenticationService: AuthenticationServicing
    
    
    init(
        networkClient: NetworkDataTransporting,
        authenticationService: AuthenticationService
    ) {
        self.networkClient = networkClient
        self.authenticationService = authenticationService
    }
    
    //  TODO: - Use auth service to inject authorization headers into requests for endpoints that need it 
}
