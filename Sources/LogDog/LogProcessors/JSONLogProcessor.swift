import Foundation

public struct JSONLogProcessor: LogProcessor {
    
    public typealias Input = Void
    public typealias Output = Data
    
    public var contextCaptures: [String : () -> LossLessMetadataValueConvertible?] = [:]
    
    public init() {
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Void>) throws -> ProcessedLogEntry<Data> {
        try logEntry.map {
            try JSONEncoder().encode(logEntry.rawLogEntry)
        }
    }
}
