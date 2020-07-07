import Foundation

public struct JSONLogFromatter: LogFormatter {
    
    public typealias I = Void
    public typealias O = Data
    
    public init() { }
    
    public func format(_ log: FormattedLogEntry<Void>) throws -> FormattedLogEntry<Data> {
        try log.map {
            try JSONEncoder().encode(log.rawLog)
        }
    }
}
