import Foundation

public struct MultiplexLogAppender<Output>: LogAppender {
    private let concurrent: Bool

    private let appenders: [AnyLogAppender<Output>]

    public init<A, B>(concurrent: Bool = false, _ a: A, _ b: B) where
        A: LogAppender, A.Output == Output,
        B: LogAppender, B.Output == Output
    {
        self.concurrent = concurrent
        appenders = [.init(a), .init(b)]
    }

    public init<A, B, C>(concurrent: Bool = false, _ a: A, _ b: B, _ c: C) where
        A: LogAppender, A.Output == Output,
        B: LogAppender, B.Output == Output,
        C: LogAppender, C.Output == Output
    {
        self.concurrent = concurrent
        appenders = [.init(a), .init(b), .init(c)]
    }

    public init<A, B, C, D>(concurrent: Bool = false, _ a: A, _ b: B, _ c: C, _ d: D) where
        A: LogAppender, A.Output == Output,
        B: LogAppender, B.Output == Output,
        C: LogAppender, C.Output == Output,
        D: LogAppender, D.Output == Output
    {
        self.concurrent = concurrent
        appenders = [.init(a), .init(b), .init(c), .init(d)]
    }

    public func append(_ record: LogRecord<Output>) throws {
        var hasError = false
        var errors: [Swift.Error?] = Array(repeating: nil, count: appenders.count)

        if concurrent {
            let queue = DispatchQueue(label: "com.v2ambition.LogDog.ConcurrentLogAppender.\(UUID().uuidString)",
                                      attributes: .concurrent)
            let group = DispatchGroup()

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
        } else {
            for i in appenders.indices {
                do {
                    try appenders[i].append(record)
                } catch {
                    errors[i] = error
                    hasError = true
                }
            }
        }

        if hasError {
            throw LogError.multiplex(errors)
        }
    }
}
