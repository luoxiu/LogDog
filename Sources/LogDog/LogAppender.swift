public protocol LogAppender {
    associatedtype Output

    func append(_ record: LogRecord<Output>) throws
}
