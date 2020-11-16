// An expressive DSL for creating matching filters.

public extension LogSink {
    func when<T>(_ transform: @escaping (LogRecord<Output>) -> T) -> LogSinks.When<Self, T> {
        .init(sink: self, transform: .init(transform))
    }

    func when<T>(_ transform: LogSinks.When<Self, T>.Transform) -> LogSinks.When<Self, T> {
        .init(sink: self, transform: transform)
    }
}

public extension LogSinks.When where T: StringProtocol {
    func contains<S: StringProtocol>(_ other: S) -> LogSinks.When<Sink, T>.Match {
        .init(when: self) {
            $0.contains(other)
        }
    }

    func includes<S: StringProtocol>(_ other: S) -> LogSinks.When<Sink, T>.Match {
        .init(when: self) {
            $0.contains(other)
        }
    }

    func excludes<S: StringProtocol>(_ other: S) -> LogSinks.When<Sink, T>.Match {
        .init(when: self) {
            !$0.contains(other)
        }
    }

    func hasPrefix<Prefix>(_ prefix: Prefix) -> LogSinks.When<Sink, T>.Match where Prefix: StringProtocol {
        .init(when: self) {
            $0.hasPrefix(prefix)
        }
    }

    func hasSuffix<Suffix>(_ suffix: Suffix) -> LogSinks.When<Sink, T>.Match where Suffix: StringProtocol {
        .init(when: self) {
            $0.hasSuffix(suffix)
        }
    }

    func start<Prefix>(with prefix: Prefix) -> LogSinks.When<Sink, T>.Match where Prefix: StringProtocol {
        .init(when: self) {
            $0.hasPrefix(prefix)
        }
    }

    func end<Prefix>(with prefix: Prefix) -> LogSinks.When<Sink, T>.Match where Prefix: StringProtocol {
        .init(when: self) {
            $0.hasSuffix(prefix)
        }
    }
}

public extension LogSinks.When where T == String {
    func match(_ regexp: String) -> LogSinks.When<Sink, T>.Match {
        .init(when: self) {
            $0.range(of: regexp, options: .regularExpression, range: nil, locale: nil) != nil
        }
    }
}

public extension LogSinks.When where T: Equatable {
    func equals(_ other: T) -> LogSinks.When<Sink, T>.Match {
        .init(when: self) {
            $0 == other
        }
    }
}

public extension LogSinks.When where T == Logger.Level {
    func greater(than level: T) -> LogSinks.When<Sink, T>.Match {
        .init(when: self) {
            $0 > level
        }
    }

    func greaterThanOrEqualTo(_ level: T) -> LogSinks.When<Sink, T>.Match {
        .init(when: self) {
            $0 >= level
        }
    }
}

public extension LogSinks.When.Match {
    var allow: LogSinks.When<Sink, T>.Match.Do {
        .init(match: self, action: .allow)
    }

    var deny: LogSinks.When<Sink, T>.Match.Do {
        .init(match: self, action: .deny)
    }
}

public extension LogSinks {
    struct When<Sink: LogSink, T> {
        public struct Transform {
            public let transform: (LogRecord<Sink.Output>) -> T

            public init(_ transform: @escaping (LogRecord<Sink.Output>) -> T) {
                self.transform = transform
            }
        }

        public let sink: Sink
        public let transform: Transform

        public init(sink: Sink, transform: Transform) {
            self.sink = sink
            self.transform = transform
        }

        public struct Match {
            public let when: When

            public let match: (T) -> Bool

            public init(when: When, match: @escaping (T) -> Bool) {
                self.when = when
                self.match = match
            }

            public struct Do: LogSink {
                public typealias Input = Sink.Input
                public typealias Output = Sink.Output

                public let match: Match

                public enum Action {
                    case deny
                    case allow
                }

                public let action: Action

                public init(match: Match, action: Action) {
                    self.match = match
                    self.action = action
                }

                public func beforeSink(_ entry: inout LogEntry) {
                    match.when.sink.beforeSink(&entry)
                }

                public func sink(_ record: LogRecord<Sink.Input>, next: @escaping LogSinkNext<Sink.Output>) {
                    record.sink(
                        from: match.when.sink,
                        next: next
                    ) { record in
                        let t = match.when.transform.transform(record)

                        let matches = match.match(t)

                        switch action {
                        case .allow:
                            return matches ? record.output : nil
                        case .deny:
                            return matches ? nil : record.output
                        }
                    }
                }
            }
        }
    }
}

public extension LogSinks.When.Transform {
    static var level: LogSinks.When<Sink, Logger.Level>.Transform {
        .init {
            $0.entry.level
        }
    }

    static var message: LogSinks.When<Sink, String>.Transform {
        .init {
            String(describing: $0.entry.message)
        }
    }

    static var source: LogSinks.When<Sink, String>.Transform {
        .init {
            String(describing: $0.entry.source)
        }
    }

    static var path: LogSinks.When<Sink, String>.Transform {
        .init {
            $0.entry.file
        }
    }

    static var filename: LogSinks.When<Sink, String>.Transform {
        .init {
            LogHelper.basename(of: $0.entry.file)
        }
    }
}
