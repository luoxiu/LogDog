@testable import LogDog
import XCTest

private class A {}

final class LazyTests: XCTestCase {
    func testLazy() {
        let lazy = AtomicLazy<A>()

        let a = lazy.get("key", whenNotFound: A())
        let b = lazy.get("key", whenNotFound: A())

        XCTAssertTrue(a === b)

        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            _ = lazy.get(0, whenNotFound: A())
        }

        XCTAssertEqual(lazy.snapshot().count, 2)
    }
}
