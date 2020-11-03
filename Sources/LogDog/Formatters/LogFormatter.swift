public protocol LogFormatter {
    associatedtype Input
    associatedtype Output
    
    var hooks: [LogHook]? { get }
    
    func format(_ record: LogRecord<Input>) throws -> Output?
}

extension LogFormatter {
    
    public var hooks: [LogHook]? { nil }
}
