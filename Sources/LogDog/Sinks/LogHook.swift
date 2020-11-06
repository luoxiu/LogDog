public protocol LogHook: LogSink where Output == Input {
    func hook(_ entry: LogEntry) throws -> Void
}

public extension LogHook {
    
    func sink(_ record: LogRecord<Input>, next: @escaping (Result<LogRecord<Output>?, Error>) -> Void) {
        
        do {
            try hook(record.entry)
            
            next(.success(record))
        } catch {
            next(.failure(error))
        }
    }
}

