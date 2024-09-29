import Foundation


public protocol NetworkDataTransporting: Sendable {
    func sendRequest(_ request: URLRequest) async throws -> (Data, URLResponse)
    func upload(_ request: URLRequest, from data: Data) async throws -> (Progress, URLResponse)
    func download(_ request: URLRequest) async throws -> (URL, URLResponse)
}



//  MARK: - Default Implementation
extension URLSession: NetworkDataTransporting {
    
    public func sendRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await data(for: request)
        return (data, response)
    }

    
    public func upload(_ request: URLRequest, from data: Data) async throws -> (Progress, URLResponse) {
        let progress = Progress(totalUnitCount: Int64(data.count))
        let (responseData, response) = try await upload(for: request, from: data)
        progress.completedUnitCount = Int64(responseData.count)
        return (progress, response)
    }

    
    public func download(_ request: URLRequest) async throws -> (URL, URLResponse) {
        let (url, response) = try await download(for: request)
        return (url, response)
    }
}
