import Logging

extension Logger.Level {
    
    enum OutputStyle {
        /// ["😶", "😐", "😮", "😲", "😨", "😱", "💀"]
        case emoji
        case initial
        case uppercase
        case lowercase
    }
    private static let emojis = ["😶", "😐", "😮", "😲", "😨", "😱", "💀"]
    
    func output(_ style: OutputStyle) -> String {
        switch style {
        case .emoji:
            return Self.emojis[intValue]
        case .initial:
            return String(rawValue.first!)
        case .uppercase:
            return rawValue.uppercased()
        case .lowercase:
            return rawValue.lowercased()
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
