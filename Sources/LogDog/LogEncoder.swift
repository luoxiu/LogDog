import Foundation

public protocol LogEncoder {

    associatedtype Output

    func encode<T>(_ value: T) throws -> Self.Output where T : Encodable
}

extension JSONEncoder: LogEncoder { }

extension PropertyListEncoder: LogEncoder { }



struct AnyLogEncoder<Output>: LogEncoder {
    
    private let encoder: AbstractEncoder<Output>
    
    init<Encoder>(_ encoder: Encoder) where Encoder: LogEncoder, Encoder.Output == Output {
        self.encoder = EncoderBox(encoder)
    }
    
    func encode<T>(_ value: T) throws -> Output where T : Encodable {
        try encoder.encode(value)
    }
}

private class AbstractEncoder<Output>: LogEncoder {
    func encode<T>(_ value: T) throws -> Output where T : Encodable {
        fatalError()
    }
}

private final class EncoderBox<Encoder>: AbstractEncoder<Encoder.Output> where Encoder: LogEncoder {
    private let encoder: Encoder
    
    init(_ encoder: Encoder) {
        self.encoder = encoder
    }
    
    override func encode<T>(_ value: T) throws -> Output where T : Encodable {
        try encoder.encode(value)
    }
}
