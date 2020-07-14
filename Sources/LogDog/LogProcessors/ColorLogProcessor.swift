public struct ColorLogProcessor: LogProcessor {
    
    public typealias Input = String
    public typealias Output = String
    
    public let transform: (Logger.Level) -> TerminalColor
    
    public var contextCaptures: [String : () -> LossLessMetadataValueConvertible?] = [:]
    
    public init(_ transform: @escaping (Logger.Level) -> TerminalColor) {
        self.transform = transform
    }
    
    public init() {
        self.init {
            Self.preferredColor(for: $0)
        }
    }
    
    public func process(_ logEntry: ProcessedLogEntry<String>) throws -> ProcessedLogEntry<String> {
        let fgColor = transform(logEntry.rawLogEntry.level)
        let style = Style(fgColor: fgColor)
        return ProcessedLogEntry(logEntry.rawLogEntry, style.on(logEntry.output).description)
    }
}

extension ColorLogProcessor {
    private static let colors = [
        Color.Material.blueGrey,
        Color.Material.grey,
        Color.Material.green,
        Color.Material.lightGreen,
        Color.Material.yellow,
        Color.Material.orange,
        Color.Material.red
    ]
    
    public static func preferredColor(for level: Logger.Level) -> Color {
        switch level {
        case .trace:
            return Color.Material.blueGrey
        case .debug:
            return Color.Material.grey
        case .notice:
            return Color.Material.green
        case .info:
            return Color.Material.lightGreen
        case .warning:
            return Color.Material.yellow
        case .error:
            return Color.Material.orange
        case .critical:
            return Color.Material.red
        }
    }
}
