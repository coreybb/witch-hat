
typealias StatusCode = Int

extension StatusCode {
    var isOK: Bool {
        (200...299).contains(self)
    }
}
