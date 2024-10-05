import Foundation

public protocol JSONCoding: JSONSerializing, JSONDeserializing { }


public protocol JSONSerializing {
    var encoder: JSONEncoder { get }
}

public protocol JSONDeserializing {
    var decoder: JSONDecoder { get }
}
