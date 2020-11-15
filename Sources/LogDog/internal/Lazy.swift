import Foundation

final class AtomicLazy<T> {
    private lazy var cache: [AnyHashable: T] = [:]
    private lazy var queue = DispatchQueue(label: "com.v2ambition.LogDog.AtomicLazy", attributes: .concurrent)

    func get(_ cacheKey: AnyHashable, whenNotFound make: @autoclosure () -> T) -> T {
        if let t = queue.sync(execute: { cache[cacheKey] }) {
            return t
        }

        return queue.sync(flags: .barrier) {
            let t = make()
            cache[cacheKey] = t
            return t
        }
    }

    /// for test
    func snapshot() -> [AnyHashable: T] {
        queue.sync {
            cache
        }
    }
}
