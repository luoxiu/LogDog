import Foundation

extension Date {
    
    private static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    /// 2020-07-12T11:55:44.800+08:00
    var iso8601String: String {
        return Self.iso8601Formatter.string(from: self)
    }
}
