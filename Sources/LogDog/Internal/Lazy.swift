import Foundation

final class AtomicLazy<T> {
    private lazy var lock = NSLock()
    private lazy var lazy = Lazy<T>()

    func get(_ cacheKey: AnyHashable, whenNotFound make: () -> T) -> T {
        lock.lock()
        defer {
            lock.unlock()
        }

        return lazy.get(cacheKey, whenNotFound: make)
    }
}

final class Lazy<T> {
    private lazy var cache: [AnyHashable: T] = [:]

    func get(_ cacheKey: AnyHashable, whenNotFound make: () -> T) -> T {
        var value: T! = cache[cacheKey]

        if value == nil {
            value = make()
            cache[cacheKey] = value
        }

        return value
    }
}
