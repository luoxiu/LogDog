@testable import LogDog
import XCTest

private class A {}

final class UnwrapTests: XCTestCase {
    func testUnwrap() {
        let x: Int? = 0

        XCTAssertEqual("\(x as Any)", "Optional(0)")
        XCTAssertEqual("\(unwrap(any: x) as Any)", "Optional(0)")

        let y: Int?? = 0

        XCTAssertEqual("\(y as Any)", "Optional(Optional(0))")
        XCTAssertEqual("\(unwrap(any: y as Any) as Any)", "Optional(0)")

        let z: Int??? = 0

        XCTAssertEqual("\(z as Any)", "Optional(Optional(Optional(0)))")
        XCTAssertEqual("\(unwrap(any: z as Any) as Any)", "Optional(0)")
    }
}
