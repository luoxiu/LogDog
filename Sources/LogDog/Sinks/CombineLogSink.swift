public extension LogSink {
    func combine<Other>(_ other: Other) -> CombineLogSink<Self, Other> where Other: LogSink, Other.Input == Output {
        .init(self, other)
    }
}

public func + <A, B>(_ a: A, _ b: B) -> CombineLogSink<A, B> where A: LogSink, B: LogSink, A.Output == B.Input {
    a.combine(b)
}

public struct CombineLogSink<A, B>: LogSink where A: LogSink, B: LogSink, A.Output == B.Input {
    public typealias Input = A.Input
    public typealias Output = B.Output

    private let a: A
    private let b: B

    public func beforeSink(_ entry: LogEntry) {
        a.beforeSink(entry)
        b.beforeSink(entry)
    }

    public func sink(_ record: LogRecord<A.Input>, next: (Result<LogRecord<B.Output>?, Error>) -> Void) {
        a.sink(record) { result in
            switch result {
            case let .success(mRecord):
                guard let mRecord = mRecord else {
                    next(.success(nil))
                    return
                }

                b.sink(mRecord, next: next)
            case let .failure(error):
                next(.failure(error))
            }
        }
    }

    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
}
