import Foundation

extension Data {
    
    /// Decodes the data into a specified `Decodable` type.
    ///
    /// - Parameter decoder: The `JSONDecoder` to use for decoding.
    /// - Returns: An instance of the specified `Decodable` type.
    /// - Throws: A `NetworkError` if the data is empty and the expected type is not `EmptyResponse`,
    ///           or a decoding error if the data cannot be decoded into the specified type.
    func decode<T: Decodable>(using decoder: JSONDecoder) throws -> T {
        if self.isEmpty {
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            } else {
                throw NetworkError.unexpectedEmptyResponse
            }
        } else {
            return try decoder.decode(T.self, from: self)
        }
    }
}
