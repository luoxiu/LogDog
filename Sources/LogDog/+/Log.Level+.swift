import Logging

extension Logger.Level {
    
    public enum OutputStyle {
        /// ["🟤", "🔵", "🟢", "❗️", "‼️", "❌", "🆘"]
        case emoji1
        /// ["📓", "📘", "📗", "📔", "📒", "📙", "📕"]
        case emoji2
        /// ["😶", "😐", "😮", "😲", "😨", "😱", "💀"]
        case emoji3
        case initial
        case uppercase
        case lowercase
        case custom((Logger.Level) -> String)
    }
    
    private static let emojis1 = ["🟤", "🔵", "🟢", "❗️", "‼️", "❌", "🆘"]
    private static let emojis2 = ["📓", "📘", "📗", "📔", "📒", "📙", "📕"]
    private static let emojis3 = ["😶", "😐", "😮", "😲", "😨", "😱", "💀"]
    private static let initials = ["t", "d", "i", "n", "w", "e", "c"]
    private static let uppercase = ["TRACE", "DEBUG", "INFO", "NOTICE", "WARNING", "ERROR", "CRITICAL"]
    
    public func output(_ style: OutputStyle) -> String {
        switch style {
        case .emoji1:
            return Self.emojis1[intValue]
        case .emoji2:
            return Self.emojis2[intValue]
        case .emoji3:
            return Self.emojis3[intValue]
        case .initial:
            return Self.initials[intValue]
        case .uppercase:
            return Self.uppercase[intValue]
        case .lowercase:
            return Self.uppercase[intValue].lowercased()
        case .custom(let toS):
            return toS(self)
        }
    }
}

extension Logger.Level {
    public var intValue: Int {
        switch self {
        case .trace:
            return 0
        case .debug:
            return 1
        case .info:
            return 2
        case .notice:
            return 3
        case .warning:
            return 4
        case .error:
            return 5
        case .critical:
            return 6
        }
    }
}
