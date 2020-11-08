@testable import LogDog
import XCTest

private class A: CustomStringConvertible {
    var description: String { "a" }
}

private class B: A {
    override var description: String { "b" }
}

private class C: B {
    override var description: String { "c" }
}

extension C: LogStringifyCompatible {
    var stringified: String {
        return "LogStringifyCompatible_c"
    }
}

final class LogStringifyTests: XCTestCase {
    func testSet() {
        var stringify = LogStringify()

        XCTAssertEqual(stringify.stringify(A()), "a")

        stringify.set { (_: A) -> String in
            "stringify_a"
        }
        XCTAssertEqual(stringify.stringify(A()), "stringify_a")
        XCTAssertEqual(stringify.stringify(B()), "b")

        stringify.set { (_: B) -> String in
            "stringify_b"
        }
        XCTAssertEqual(stringify.stringify(A()), "stringify_a")
        XCTAssertEqual(stringify.stringify(B()), "stringify_b")

        stringify.set { (_: B) -> String in
            "stringify_b_new"
        }
        XCTAssertEqual(stringify.stringify(A()), "stringify_a")
        XCTAssertEqual(stringify.stringify(B()), "stringify_b_new")
    }

    func testUse() {
        var stringify = LogStringify()

        stringify.use { (_: A) -> String in
            "stringify_a"
        }

        XCTAssertEqual(stringify.stringify(A()), "stringify_a")
        XCTAssertEqual(stringify.stringify(B()), "stringify_a")
        XCTAssertEqual(stringify.stringify(C()), "stringify_a")

        stringify.use { (_: B) -> String in
            "stringify_b"
        }

        XCTAssertEqual(stringify.stringify(A()), "stringify_a")
        XCTAssertEqual(stringify.stringify(B()), "stringify_a")
        XCTAssertEqual(stringify.stringify(C()), "stringify_a")

        stringify.useFirst { (_: B) -> String in
            "stringify_b"
        }

        XCTAssertEqual(stringify.stringify(A()), "stringify_a")
        XCTAssertEqual(stringify.stringify(B()), "stringify_b")
        XCTAssertEqual(stringify.stringify(C()), "stringify_b")
    }

    func testSetAndUse() {
        var stringify = LogStringify()

        stringify.set { (_: A) -> String in
            "set_stringify_a"
        }

        stringify.use { (_: A) -> String in
            "use_stringify_a"
        }

        XCTAssertEqual(stringify.stringify(A()), "set_stringify_a")
    }

    func testClear() {
        var stringify = LogStringify()

        stringify.use { (_: A) -> String in
            "stringify_a"
        }
        stringify.use { (_: B) -> String in
            "stringify_b"
        }

        stringify.clear()

        XCTAssertEqual(stringify.stringify(A()), "a")
        XCTAssertEqual(stringify.stringify(B()), "b")
        XCTAssertEqual(stringify.stringify(C()), "c")
    }

    func testMetadataValueAny() {
        LogStringify.default.use { (_: C) in
            "stringify_c"
        }
        XCTAssertEqual(Logger.MetadataValue.any(C()), .string("LogStringifyCompatible_c"))
    }
}
