import Foundation

public struct JSONLogProcessor: LogProcessor {
    
    public typealias Input = Void
    public typealias Output = Data
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public init() {
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Void>) throws -> ProcessedLogEntry<Data> {
        logEntry.map {
            try JSONEncoder().encode(logEntry.rawLogEntry)
        }
    }
}
