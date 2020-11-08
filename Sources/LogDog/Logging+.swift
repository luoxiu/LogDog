public extension LogHandler {
    subscript(metadataKey metadataKey: String) -> Logger.MetadataValue? {
        get {
            metadata[metadataKey]
        }
        set(newValue) {
            metadata[metadataKey] = newValue
        }
    }
}

extension Logger.Level {
    private static let uppercased = Logger.Level.allCases.map { $0.uppercased }

    private static let initial = [
        "T", "D", "I", "N", "W", "E", "C",
    ]

    private var intValue: Int {
        switch self {
        case .trace: return 0
        case .debug: return 1
        case .info: return 2
        case .notice: return 3
        case .warning: return 4
        case .error: return 5
        case .critical: return 6
        }
    }

    public var uppercased: String {
        Self.uppercased[intValue]
    }

    public var initial: String {
        Self.initial[intValue]
    }

    public var lowercased: String {
        rawValue
    }
}

public extension Logger {
    func t(_ message: @autoclosure () -> Logger.Message,
           metadata: @autoclosure () -> Logger.Metadata? = nil,
           source: @autoclosure () -> String? = nil,
           file: String = #file, function: String = #function, line: UInt = #line)
    {
        log(level: .trace, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    func d(_ message: @autoclosure () -> Logger.Message,
           metadata: @autoclosure () -> Logger.Metadata? = nil,
           source: @autoclosure () -> String? = nil,
           file: String = #file, function: String = #function, line: UInt = #line)
    {
        log(level: .debug, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    func i(_ message: @autoclosure () -> Logger.Message,
           metadata: @autoclosure () -> Logger.Metadata? = nil,
           source: @autoclosure () -> String? = nil,
           file: String = #file, function: String = #function, line: UInt = #line)
    {
        log(level: .info, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    func n(_ message: @autoclosure () -> Logger.Message,
           metadata: @autoclosure () -> Logger.Metadata? = nil,
           source: @autoclosure () -> String? = nil,
           file: String = #file, function: String = #function, line: UInt = #line)
    {
        log(level: .notice, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    func w(_ message: @autoclosure () -> Logger.Message,
           metadata: @autoclosure () -> Logger.Metadata? = nil,
           source: @autoclosure () -> String? = nil,
           file: String = #file, function: String = #function, line: UInt = #line)
    {
        log(level: .warning, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    func e(_ message: @autoclosure () -> Logger.Message,
           metadata: @autoclosure () -> Logger.Metadata? = nil,
           source: @autoclosure () -> String? = nil,
           file: String = #file, function: String = #function, line: UInt = #line)
    {
        log(level: .error, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    func c(_ message: @autoclosure () -> Logger.Message,
           metadata: @autoclosure () -> Logger.Metadata? = nil,
           source: @autoclosure () -> String? = nil,
           file: String = #file, function: String = #function, line: UInt = #line)
    {
        log(level: .critical, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }
}
