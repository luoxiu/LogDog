// workaround for `Encodable` as the parameter type.
private extension Encodable {
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}

struct AnyEncodable: Encodable {
    private let encodable: Encodable

    init(_ encodable: Encodable) {
        self.encodable = encodable
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try encodable.encode(to: &container)
    }
}
