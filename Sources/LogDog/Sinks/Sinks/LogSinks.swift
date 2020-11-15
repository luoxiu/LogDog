public enum LogSinks {}

public extension LogSinks {
    struct Firstly: LogSink {
        public typealias Input = Void
        public typealias Output = Void
    }

    static let firstly = Firstly()
}
