
public typealias LogSinkNext<Output> = (Result<LogRecord<Output>?, Error>) -> Void

public typealias LogRecordTransform<Output, NewOutput> = (LogRecord<Output>) throws -> NewOutput?

/// Sinks sink LogRecords.
public protocol LogSink {
    associatedtype Input
    associatedtype Output

    /// Before sinking, the sink has a chance to do something on entry.
    func beforeSink(_ entry: inout LogEntry)

    func sink(_ record: LogRecord<Input>, next: @escaping LogSinkNext<Output>)
}

public extension LogSink {
    func beforeSink(_: inout LogEntry) {
        // noop
    }
}

public extension LogSink where Input == Output {
    func sink(_ record: LogRecord<Input>, next: @escaping LogSinkNext<Output>) {
        next(.success(record))
    }
}

public extension LogRecord {
    func sink<NewOutput>(
        next: @escaping LogSinkNext<NewOutput>,
        transform: @escaping LogRecordTransform<Output, NewOutput>
    ) {
        do {
            guard let newOutput = try transform(self) else {
                next(.success(nil))
                return
            }

            next(.success(.init(entry, newOutput)))
        } catch {
            next(.failure(error))
        }
    }

    func sink<Sink, NewOutput>(
        from: Sink,
        next: @escaping LogSinkNext<NewOutput>,
        transform: @escaping LogRecordTransform<Sink.Output, NewOutput>
    )
        where Sink: LogSink, Sink.Input == Output
    {
        from.sink(self) { result in
            switch result {
            case let .failure(error):
                next(.failure(error))
            case let .success(record):
                guard let record = record else {
                    next(.success(nil))
                    return
                }

                record.sink(next: next, transform: transform)
            }
        }
    }
}
