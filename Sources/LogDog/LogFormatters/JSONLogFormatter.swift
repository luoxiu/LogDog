import Foundation

public struct JSONLogFormatter: LogFormatter {
    
    public typealias Input = Void
    public typealias Output = Data
    
    public var context: [String : () -> Logger.MetadataValue?] = [:]
    
    public let jsonEncoder: JSONEncoder
    
    public init(jsonEncoder: JSONEncoder = JSONEncoder()) {
        self.jsonEncoder = jsonEncoder
    }
    
    public func format(_ logEntry: ProcessedLogEntry<Void>) throws -> ProcessedLogEntry<Data> {
        try logEntry.map {
            try jsonEncoder.encode(logEntry.rawLogEntry)
        }
    }
}
