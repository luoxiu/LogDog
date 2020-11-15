func unwrap(any: Any?) -> Any? {
    guard let any = any else {
        return nil
    }

    let mirror = Mirror(reflecting: any)

    if mirror.displayStyle != .optional {
        return any
    }

    if let (_, any) = mirror.children.first {
        return unwrap(any: any)
    }

    return nil
}
