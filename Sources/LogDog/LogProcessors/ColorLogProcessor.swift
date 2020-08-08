public struct ColorLogProcessor: LogProcessor {
    
    public typealias Input = String
    public typealias Output = String
    
    public let colorForLevel: (Logger.Level) -> TerminalColor
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public init(colorForLevel: @escaping (Logger.Level) -> TerminalColor = Self.preferredColor) {
        self.colorForLevel = colorForLevel
    }
    
    public func process(_ logEntry: ProcessedLogEntry<String>) -> ProcessedLogEntry<String> {
        logEntry.map {
            let fgColor = colorForLevel(logEntry.rawLogEntry.level)
            let style = Style(fgColor: fgColor)
            
            return style.on($0).description
        }
    }
}

public extension LogProcessor where Self.Output == String {
    
    func color(using colorForLevel: @escaping (Logger.Level) -> TerminalColor = ColorLogProcessor.preferredColor) -> MultiplexLogProcessor<Self, ColorLogProcessor> {
        self + ColorLogProcessor(colorForLevel: colorForLevel)
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
