import Foundation

extension ByteCountFormatter {
    /// Tests for ByteCountFormatter passed on my mac, but failed on ci, and i released...
    ///
    ///     1 KB // ["1", " ", "K", "B"]
    ///     1 KB // ["1", "\u{2006}", "K", "B"]
    static func normalize(_ string: String) -> String {
        string.replacingOccurrences(of: "\u{2006}", with: " ")
    }
}
