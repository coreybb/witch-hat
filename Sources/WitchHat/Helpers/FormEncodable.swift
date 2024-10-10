import Foundation


protocol FormEncodable {
    
    /// Returns all key/value pairs returned by `asKeyValuePairs()` as `Data`.
    func asFormEncodedData(convertToSnakeCase: Bool) -> Data
    
    /// Returns a `Dictionary` of object properties and their values as key/value `String` pairs.
    /// If `CodingKeys` are being used, the default implementation of this method cannot be relied on to generate accurate keys.
    func asKeyValuePairs(convertToSnakeCase: Bool) -> [String : String]
}



//-------------------------
//  MARK: - Implementation
//-------------------------
extension FormEncodable {
    
    func asFormEncodedData(convertToSnakeCase: Bool = true) -> Data {
        asKeyValuePairs(convertToSnakeCase: convertToSnakeCase)
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)!
    }
    
    
    func asKeyValuePairs(convertToSnakeCase: Bool) -> [String : String] {
        
        var dict: [String : String] = [String : String]()

        Mirror(reflecting: self).children.forEach {
            let key: String = (convertToSnakeCase) ? $0.label!.asSnakeCase() : $0.label!
            dict[key] = String(describing: $0.value)
        }
        return dict
    }
}



fileprivate extension String {
    
    func asSnakeCase() -> String {
        
        guard !isEmpty else { return self }
    
        var words : [Range<String.Index>] = []
        var wordStart = startIndex
        var searchRange = index(after: wordStart)..<endIndex

        while let upperCaseRange = rangeOfCharacter(
            from: CharacterSet.uppercaseLetters,
            options: [], range: searchRange
        ) {
            let untilUpperCase = wordStart..<upperCaseRange.lowerBound
            words.append(untilUpperCase)
            searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
            
            guard let lowerCaseRange = rangeOfCharacter(
                from: CharacterSet.lowercaseLetters,
                options: [],
                range: searchRange
            ) else {
                wordStart = searchRange.lowerBound
                break
            }
            
            let nextCharacterAfterCapital = index(after: upperCaseRange.lowerBound)
            
            if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                wordStart = upperCaseRange.lowerBound
            } else {
                let beforeLowerIndex = index(before: lowerCaseRange.lowerBound)
                words.append(upperCaseRange.lowerBound..<beforeLowerIndex)
                wordStart = beforeLowerIndex
            }
            
            searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
        }
        
        words.append(wordStart..<searchRange.upperBound)
        
        let result = words.map({ range in
            self[range].lowercased()
        })
            .joined(separator: "_")
        
        return result
    }
}
