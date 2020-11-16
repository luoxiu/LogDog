/// Appenders append LogRecords.
///
/// The LogDog framework ships with the following impementations:
///
/// - `OSLogAppender`
/// - `TextLogAppender`
/// - `MemoryLogAppender`
/// - `MultiplexLogAppender`
///
/// Feel free to create your own custom appenders! e.g.
///
/// - `FileLogAppender`
/// - `HTTPLogAppender`
/// - `SQLiteLogAppender`
/// - `SlackLogAppeder`
///
/// Or, wrapper one of your favorite existing logging tools! e.g.
///
/// - `CocoaLumberjackLogAppender`
/// - `NSLoggerLogAppender`
///
/// You can find many interesting logDog extensions at [LogDogCommunity](https://github.com/LogDogCommunity).
public protocol LogAppender {
    associatedtype Output

    /// Append a LogRecord.
    func append(_ record: LogRecord<Output>) throws
}
