public extension Logger.MetadataValue {
    /// If `any` conforms `LogStringifyCompatible`, this methods returns `.string(any.stringified)`.
    /// Otherwise it returns `stringify.string(stringify.stringify(any))`.
    static func any(_ any: Any?, _ stringify: LogStringify = .default) -> Logger.MetadataValue {
        
        guard let any = unwrap(any: any) else {
            return .string("nil")
        }
        
        if let any = any as? LogStringifyCompatible {
            return .string(any.stringified)
        }
        
        return .string(stringify.stringify(any))
    }
}

private func unwrap(any: Any?) -> Any? {
    guard let any = any else {
        return nil
    }

    let mirror = Mirror(reflecting: any)
    if mirror.displayStyle != .optional {
        return any
    }
    
    if let (_, some) = mirror.children.first {
        return unwrap(any: some)
    }
    
    return nil
}
