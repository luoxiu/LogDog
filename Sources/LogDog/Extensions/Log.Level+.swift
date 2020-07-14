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
    
    public func output(_ style: OutputStyle) -> String {
        switch style {
        case .emoji1:
            return Self.emojis1[intValue]
        case .emoji2:
            return Self.emojis2[intValue]
        case .emoji3:
            return Self.emojis3[intValue]
        case .initial:
            return String(rawValue.first!)
        case .uppercase:
            return rawValue.uppercased()
        case .lowercase:
            return rawValue.lowercased()
        case .custom(let transform):
            return transform(self)
        }
    }
}

extension Logger.Level {
    private var intValue: Int {
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
