public protocol LogFilter: LogSink where Output == Input {
    func filter(_ record: LogRecord<Input>) -> Bool
}

public extension LogFilter {
    func sink(_ record: LogRecord<Input>, next: (Result<LogRecord<Output>?, Error>) -> Void) {
        guard filter(record) else {
            return
        }
        next(.success(record))
    }
}
