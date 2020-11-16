public extension LogSink {
    func concat<Other>(_ other: Other) -> LogSinks.Concat<Self, Other> where Other: LogSink, Other.Input == Output {
        .init(self, other)
    }
}

public func + <A, B>(_ a: A, _ b: B) -> LogSinks.Concat<A, B> where A: LogSink, B: LogSink, B.Input == A.Output {
    a.concat(b)
}

public extension LogSinks {
    struct Concat<A, B>: LogSink where A: LogSink, B: LogSink, A.Output == B.Input {
        public typealias Input = A.Input
        public typealias Output = B.Output

        public let a: A
        public let b: B

        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        public func beforeSink(_ entry: inout LogEntry) {
            a.beforeSink(&entry)
            b.beforeSink(&entry)
        }

        public func sink(_ record: LogRecord<A.Input>, next: @escaping (Result<LogRecord<B.Output>?, Error>) -> Void) {
            a.sink(record) { result in
                switch result {
                case let .success(record):
                    guard let record = record else {
                        next(.success(nil))
                        return
                    }

                    b.sink(record, next: next)
                case let .failure(error):
                    next(.failure(error))
                }
            }
        }
    }
}
