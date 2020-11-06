public protocol LogFormatter: LogSink {
    /// Be aware that this method may be called asynchronously.
    func format(_ record: LogRecord<Input>) throws -> Output?
}

public extension LogFormatter {
    func sink(_ record: LogRecord<Input>, next: (Result<LogRecord<Output>?, Error>) -> Void) {
        let result = Result<LogRecord<Output>?, Error> {
            guard let output = try format(record) else {
                return nil
            }
            return LogRecord<Output>(record.entry, output)
        }

        next(result)
    }
}
