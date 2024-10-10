typealias StatusCode = Int


extension StatusCode {
    var isOK: Bool {
        (200...299).contains(self)
    }
    
    var isUnauthorized: Bool {
        self == 401
    }
}
