/// Appenders append LogRecords.
///
/// The LogDog framework ships with the following impementations:
///
/// - `OSLogAppender`
/// - `TextLogAppender`
/// - `MemoryLogAppender`
/// - `MultiplexLogAppender`
///
/// You can create your own custom appenders freely, e.g.
///
/// - `FileLogAppender` - I'm also working on this, : )
/// - `SQLiteLogAppender`
/// - `SlackLogAppeder`
///
/// Or, wrapper one of your favorite existing logging tools! e.g.
///
/// - `CocoaLumberjackLogAppender`
/// - `NSLoggerLogAppender`
public protocol LogAppender {
    associatedtype Output

    /// Append a LogRecord.
    func append(_ record: LogRecord<Output>) throws
}
