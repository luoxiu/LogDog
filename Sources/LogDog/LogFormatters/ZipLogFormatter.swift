import Foundation
@_exported import Gzip

public struct ZipLogFormatter: LogFormatter {
    
    public typealias I = Data
    public typealias O = Data
    
    public let compressionLevel: CompressionLevel
    
    public init(_ compressionLevel: CompressionLevel) {
        self.compressionLevel = compressionLevel
    }
    
    public func format(_ log: FormattedLogEntry<Data>) throws -> FormattedLogEntry<Data> {
        try log.map {
            try $0.gzipped(level: compressionLevel)
        }
    }
}

