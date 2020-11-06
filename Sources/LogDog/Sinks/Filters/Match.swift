public extension LogSink {
    var level: LogFilters.Matching<Self, Logger.Level> {
        .init(self) {
            $0.entry.level
        }
    }

    var message: LogFilters.Matching<Self, String> {
        .init(self) {
            String(describing: $0.entry.message)
        }
    }

    var source: LogFilters.Matching<Self, String> {
        .init(self) {
            String(describing: $0.entry.source)
        }
    }

    var path: LogFilters.Matching<Self, String> {
        .init(self) {
            $0.entry.file
        }
    }

    var filename: LogFilters.Matching<Self, String> {
        .init(self) {
            LogHelper.basename(of: $0.entry.file)
        }
    }
}

public extension LogFilters {
    struct Matching<Sink: LogSink, R> {
        private let sink: Sink

        private let map: (LogRecord<Sink.Output>) -> R

        public init(_ sink: Sink, _ map: @escaping (LogRecord<Sink.Output>) -> R) {
            self.sink = sink
            self.map = map
        }

        public struct Match: LogFilter {
            public typealias Input = Sink.Output
            public typealias Output = Input

            private let matching: Matching<Sink, R>

            private let predicate: (R) -> Bool

            public init(_ matching: Matching<Sink, R>, _ predicate: @escaping (R) -> Bool) {
                self.matching = matching
                self.predicate = predicate
            }

            public func filter(_ record: LogRecord<Input>) -> Bool {
                predicate(matching.map(record))
            }
        }
    }
}

public extension LogFilters.Matching where R: StringProtocol {
    func includes<S: StringProtocol>(_ other: S) -> LogSinks.Concat<Sink, Match> {
        sink + Match(self) { $0.contains(other) }
    }

    func excludes<S: StringProtocol>(_ other: S) -> LogSinks.Concat<Sink, Match> {
        sink + Match(self) { !$0.contains(other) }
    }

    func hasPrefix<Prefix>(_ prefix: Prefix) -> LogSinks.Concat<Sink, Match> where Prefix: StringProtocol {
        sink + Match(self) { !$0.hasPrefix(prefix) }
    }

    func hasSuffix<Suffix>(_ suffix: Suffix) -> LogSinks.Concat<Sink, Match> where Suffix: StringProtocol {
        sink + Match(self) { !$0.hasSuffix(suffix) }
    }
}

public extension LogFilters.Matching where R == String {
    func match(_ regexp: String) -> LogSinks.Concat<Sink, Match> {
        sink + Match(self) {
            $0.range(of: regexp, options: .regularExpression, range: nil, locale: nil) != nil
        }
    }
}

public extension LogFilters.Matching where R: Equatable {
    func equals(_ other: R) -> LogSinks.Concat<Sink, Match> {
        sink + Match(self) { $0 == other }
    }
}
