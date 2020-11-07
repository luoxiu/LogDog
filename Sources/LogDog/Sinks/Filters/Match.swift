public extension LogSink {
    func when<T>(_ transform: @escaping (LogRecord<Output>) -> T) -> LogFilters.When<Self, T> {
        .init(self, .init(transform))
    }

    func when<T>(_ transform: LogFilters.When<Self, T>.Transform) -> LogFilters.When<Self, T> {
        .init(self, transform)
    }
}

public extension LogFilters.Match {
    var allow: LogSinks.Concat<Sink, LogFilters.Directive<Sink, T>> {
        when.sink + .init(self, action: .allow)
    }

    var deny: LogSinks.Concat<Sink, LogFilters.Directive<Sink, T>> {
        when.sink + .init(self, action: .deny)
    }
}

public extension LogFilters {
    struct When<Sink: LogSink, T> {
        public struct Transform {
            public let transform: (LogRecord<Sink.Output>) -> T

            public init(_ transform: @escaping (LogRecord<Sink.Output>) -> T) {
                self.transform = transform
            }
        }

        public let sink: Sink
        public let transform: Transform

        public init(_ sink: Sink, _ transform: Transform) {
            self.sink = sink
            self.transform = transform
        }
    }

    struct Match<Sink: LogSink, T> {
        public let when: When<Sink, T>

        public let isIncluded: (T) -> Bool

        public init(_ when: When<Sink, T>, _ isIncluded: @escaping (T) -> Bool) {
            self.when = when
            self.isIncluded = isIncluded
        }
    }

    struct Directive<Sink: LogSink, T>: LogFilter {
        public typealias Input = Sink.Output
        public typealias Output = Sink.Output

        public let match: Match<Sink, T>

        public enum Action {
            case deny
            case allow
        }

        public let action: Action

        public init(_ match: Match<Sink, T>, action: Action) {
            self.match = match
            self.action = action
        }

        public func filter(_ record: LogRecord<Output>) -> Bool {
            let t = match.when.transform.transform(record)
            let isIncluded = match.isIncluded(t)

            switch action {
            case .allow:
                return isIncluded
            case .deny:
                return !isIncluded
            }
        }
    }
}

public extension LogFilters.When.Transform {
    static var level: LogFilters.When<Sink, Logger.Level>.Transform {
        .init {
            $0.entry.level
        }
    }

    static var message: LogFilters.When<Sink, String>.Transform {
        .init {
            String(describing: $0.entry.message)
        }
    }

    static var source: LogFilters.When<Sink, String>.Transform {
        .init {
            String(describing: $0.entry.source)
        }
    }

    static var path: LogFilters.When<Sink, String>.Transform {
        .init {
            $0.entry.file
        }
    }

    static var filename: LogFilters.When<Sink, String>.Transform {
        .init {
            LogHelper.basename(of: $0.entry.file)
        }
    }
}

public extension LogFilters.When where T: StringProtocol {
    func includes<S: StringProtocol>(_ other: S) -> LogFilters.Match<Sink, T> {
        .init(self) {
            $0.contains(other)
        }
    }

    func excludes<S: StringProtocol>(_ other: S) -> LogFilters.Match<Sink, T> {
        .init(self) {
            !$0.contains(other)
        }
    }

    func hasPrefix<Prefix>(_ prefix: Prefix) -> LogFilters.Match<Sink, T> where Prefix: StringProtocol {
        .init(self) {
            $0.hasPrefix(prefix)
        }
    }

    func hasSuffix<Suffix>(_ suffix: Suffix) -> LogFilters.Match<Sink, T> where Suffix: StringProtocol {
        .init(self) {
            $0.hasSuffix(suffix)
        }
    }
}

public extension LogFilters.When where T == String {
    func match(_ regexp: String) -> LogFilters.Match<Sink, T> {
        .init(self) {
            $0.range(of: regexp, options: .regularExpression, range: nil, locale: nil) != nil
        }
    }
}

public extension LogFilters.When where T: Equatable {
    func equals(_ other: T) -> LogFilters.Match<Sink, T> {
        .init(self) {
            $0 == other
        }
    }
}
