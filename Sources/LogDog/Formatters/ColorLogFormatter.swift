import Rainbow
import Logging

public struct ColorLogFormatter: LogFormatter {
    
    public typealias I = String
    public typealias O = String
    
    private let color: (Logger.Level) -> TerminalColor
    
    public init(_ color: @escaping (Logger.Level) -> TerminalColor) {
        self.color = color
    }
    
    public init() {
        self.color = {
            Self.preferredColor(for: $0)
        }
    }
    
    public func format(_ log: Log<String>) -> Log<String> {
        var style = ck
        style.fgColor = color(log.rawLog.level)
        return Log(log.rawLog, style.on(log.output).description)
    }
}

extension ColorLogFormatter {
    private static let colors = [
        Color.grey,
        Color(hex: 0x2196F3),
        Color(hex: 0x4CAF50),
        Color.greenYellow,
        Color(hex: 0xFFC107),
        Color(hex: 0xF44336),
        Color.red
    ]
    
    public static func preferredColor(for level: Logger.Level) -> Color {
        return Self.colors[level.intValue]
    }
}
