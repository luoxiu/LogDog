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
            "set_a"
        }
        XCTAssertEqual(stringify.stringify(A()), "set_a")
        XCTAssertEqual(stringify.stringify(B()), "b")

        stringify.set { (_: B) -> String in
            "set_b"
        }
        XCTAssertEqual(stringify.stringify(A()), "set_a")
        XCTAssertEqual(stringify.stringify(B()), "set_b")

        stringify.set { (_: B) -> String in
            "set_b_new"
        }
        XCTAssertEqual(stringify.stringify(A()), "set_a")
        XCTAssertEqual(stringify.stringify(B()), "set_b_new")
    }

    func testUse() {
        var stringify = LogStringify()

        stringify.use { (_: A) -> String in
            "use_a"
        }

        XCTAssertEqual(stringify.stringify(A()), "use_a")
        XCTAssertEqual(stringify.stringify(B()), "use_a")
        XCTAssertEqual(stringify.stringify(C()), "use_a")

        stringify.use { (_: B) -> String in
            "use_b"
        }

        XCTAssertEqual(stringify.stringify(A()), "use_a")
        XCTAssertEqual(stringify.stringify(B()), "use_a")
        XCTAssertEqual(stringify.stringify(C()), "use_a")
    }

    func testSetAndUse() {
        var stringify = LogStringify()

        stringify.set { (_: A) -> String in
            "set_a"
        }

        stringify.use { (_: A) -> String in
            "use_a"
        }

        XCTAssertEqual(stringify.stringify(A()), "set_a")
    }

    func testClear() {
        var stringify = LogStringify()

        stringify.set { (_: A) -> String in
            "set_a"
        }
        stringify.set { (_: B) -> String in
            "set_b"
        }

        stringify.clear()

        XCTAssertEqual(stringify.stringify(A()), "a")
        XCTAssertEqual(stringify.stringify(B()), "b")
        XCTAssertEqual(stringify.stringify(C()), "c")
    }

    func testDefault() {
        let data = Data(repeating: 0, count: 1024)
        XCTAssertEqual(
            ByteCountFormatter.normalize(Logger.MetadataValue.any(data).description), "1 KB"
        )
    }

    func testMetadataValueAny() {
        LogStringify.default.use { (_: C) in
            "use_c"
        }
        XCTAssertEqual(Logger.MetadataValue.any(C()), .string("LogStringifyCompatible_c"))
    }
}
