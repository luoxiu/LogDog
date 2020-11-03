import Foundation

public struct ConcurrentLogAppender<Output>: LogAppender {
    
    public enum Error: Swift.Error {
        case errors([Swift.Error?])
    }
    
    private let appenders: [AnyLogAppender<Output>]
    
    private let queue = DispatchQueue(label: "com.v2ambition.LogDog.ConcurrentLogAppender", attributes: .concurrent)
    private let group = DispatchGroup()
    
    public init<A, B>(_ a: A, _ b: B)
        where A: LogAppender, A.Output == Output, B: LogAppender, B.Output == Output
    {
        self.appenders = [.init(a), .init(b)]
    }
    
    public init<A, B, C>(_ a: A, _ b: B, _ c: C) where
        A: LogAppender, A.Output == Output,
        B: LogAppender, B.Output == Output,
        C: LogAppender, C.Output == Output
    {
        self.appenders = [.init(a), .init(b), .init(c)]
    }
    
    public init<A, B, C, D>(_ a: A, _ b: B, _ c: C, _ d: D) where
        A: LogAppender, A.Output == Output,
        B: LogAppender, B.Output == Output,
        C: LogAppender, C.Output == Output,
        D: LogAppender, D.Output == Output
    {
        self.appenders = [.init(a), .init(b), .init(c), .init(d)]
    }
    
    public func append(_ record: LogRecord<Output>) throws {
        var hasError = false
        var errors: [Swift.Error?] = Array(repeating: nil, count: appenders.count)
        
        for (i, appender) in appenders.enumerated() {
            queue.async(group: group) {
                do {
                    try appender.append(record)
                } catch {
                    errors[i] = error
                    hasError = true
                }
            }
        }
        
        group.wait()
        
        if hasError {
            throw Error.errors(errors)
        }
    }
}
