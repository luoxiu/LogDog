import Foundation

extension Date {
    
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    private static let isoFormatter = ISO8601DateFormatter()
    
    private static let fallbackISOFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    var isoString: String {
        if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            return Self.isoFormatter.string(from: self)
        }
        return Self.fallbackISOFormatter.string(from: self)
    }
    
    var timeString: String {
        Self.timeFormatter.string(from: self)
    }
}
