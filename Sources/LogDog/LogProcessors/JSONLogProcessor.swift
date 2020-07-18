import Foundation

public struct JSONLogProcessor: LogProcessor {
    
    public typealias Input = Void
    public typealias Output = Data
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public let jsonEncoder: JSONEncoder
    
    public init(jsonEncoder: JSONEncoder = JSONEncoder()) {
        self.jsonEncoder = jsonEncoder
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Void>) throws -> ProcessedLogEntry<Data> {
        try logEntry.map {
            try jsonEncoder.encode(logEntry.rawLogEntry)
        }
    }
}
