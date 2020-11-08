public protocol LogFilter: LogSink where Output == Input {
    func filter(_ record: LogRecord<Input>) throws -> Bool
}

public extension LogFilter {
    func sink(_ record: LogRecord<Input>, next: (Result<LogRecord<Output>?, Error>) -> Void) {
        let result = Result<LogRecord<Output>?, Error> {
            guard try filter(record) else {
                return nil
            }
            return record
        }

        next(result)
    }
}
