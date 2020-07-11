open class ColorLogProcessor: LogProcessor<String, String> {
    
    private let color: (Logger.Level) -> TerminalColor
    
    public init(_ color: @escaping (Logger.Level) -> TerminalColor) {
        self.color = color
        super.init {
            let fgColor = color($0.raw.level)
            let style = Style(fgColor: fgColor)
            return ProcessedLogEntry($0.raw, style.on($0.output).description)
        }
    }
    
    public convenience init() {
        self.init {
            Self.preferredColor(for: $0)
        }
    }
}

extension ColorLogProcessor {
    private static let colors = [
        Color(hex: 0x808080),
        Color(hex: 0x2196F3),
        Color(hex: 0x4CAF50),
        Color(hex: 0xADFF2F),
        Color(hex: 0xFFC107),
        Color(hex: 0xF44336),
        Color(hex: 0xFF0000)
    ]
    
    public static func preferredColor(for level: Logger.Level) -> Color {
        return Self.colors[level.intValue]
    }
}
