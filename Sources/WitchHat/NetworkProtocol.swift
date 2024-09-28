import Foundation


public protocol NetworkProtocol: RequestProtocol, UploadProtocol, DownloadProtocol { }


public protocol RequestProtocol {
    func request <T: Decodable> (_ endpoint: Endpoint) async throws -> T
}


public protocol UploadProtocol {
    func upload(_ endpoint: Endpoint, data: Data) async throws -> Progress
}


public protocol DownloadProtocol {
    func download(_ endpoint: Endpoint) async throws -> URL
}
