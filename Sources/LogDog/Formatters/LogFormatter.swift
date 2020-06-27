public protocol LogFormatter {
    
    associatedtype I
    associatedtype O
    
    func format(_ log: Log<I>) throws -> Log<O>
}
