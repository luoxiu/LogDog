import Foundation

extension TimeInterval {
    
    /// Formatted.
    ///
    ///     // +0.123ms
    ///     // +1.23s
    ///     // +1m23s
    ///     // +1h2m3s
    ///     // +1d2h3m
    var formatted: String {
        enum Lazy {
            static let dateComponentsFormatter: DateComponentsFormatter = {
                let fmt = DateComponentsFormatter()
                fmt.calendar = nil
                fmt.allowedUnits = [.day, .hour, .minute, .second]
                fmt.allowsFractionalUnits = true
                fmt.unitsStyle = .abbreviated
                return fmt
            }()
            
            static let numberFormatter: NumberFormatter = {
                let fmt = NumberFormatter()
                fmt.maximumFractionDigits = 3
                return fmt
            }()
        }
        
        let magnitude = self.magnitude
        var result = "0ms"
        
        if magnitude < 1, let _str = Lazy.numberFormatter.string(from: NSNumber(value: magnitude * 1000)) {
            result = _str + "ms"
        } else if magnitude < 60 {
            if let _str = Lazy.numberFormatter.string(from: NSNumber(value: magnitude)) {
                result = _str + "s"
            }
        } else {
            if let _str = Lazy.dateComponentsFormatter.string(from: magnitude) {
                result = _str
            }
        }
        
        let prefix = self < 0 ? "-" : "+"
        return prefix + result.replacingOccurrences(of: " ", with: "")
    }
}
